//
//  ViewController.swift
//  productStore
//
//  Created by Minerva Nolasco Espino on 06/10/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var productStoreTableView: UITableView!
    
    let characterSet = CharacterSet.letters
    
    private lazy var productStoreVM = ProductStoreViewModel()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredProducts: [ProductStoreModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productStoreTableView.register(UINib(nibName: "ProductTableViewCell", bundle: Bundle(for: ProductTableViewCell.self)), forCellReuseIdentifier: "productCell")
        self.productStoreVM.requestProductStore()
        productStoreVM.productModel.bind { [weak self] productModel in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.productStoreTableView.reloadData()
            }
        }
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search products"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification: notification) }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                       object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification: notification) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = productStoreTableView.indexPathForSelectedRow {
            productStoreTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    func filterProductsForSearch(_ searchText : String) {
        filteredProducts = productStoreVM.productModel.value?.filter({ products -> Bool in
            return products.title.lowercased().contains(searchText.lowercased())
        }) ?? filteredProducts
        productStoreTableView.reloadData()
    }
    
    
    func handleKeyboard(notification: Notification) {
        guard
            let info = notification.userInfo,
            let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        
        _ = keyboardFrame.cgRectValue.size.height
        self.view.layoutIfNeeded()
    }
    
}

extension ViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredProducts.count
        }
        return productStoreVM.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell" , for: indexPath) as? ProductTableViewCell,
              let product = isFiltering ? filteredProducts[indexPath.row] : productStoreVM.getProduct(at: indexPath.row) else { return UITableViewCell() }
        
        cell.productImageCell.downloadImage(from: product.image)
        cell.productLabel.text = product.title
        cell.priceLabel.text = "$ \(String(product.price))"
        
        return cell
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloadImage(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension  ViewController : UISearchResultsUpdating {
    func  updateSearchResults ( for  searchController : UISearchController ) {
        let searchBar = searchController.searchBar
        filterProductsForSearch(searchBar.text!)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterProductsForSearch(searchBar.text!)
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let regex = "^[a-zA-Z ]{0,15}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: text)
    }
}
