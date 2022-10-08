//
//  ProductStoreViewModel.swift
//  productStore
//
//  Created by Minerva Nolasco Espino on 06/10/22.
//

import Foundation

public class ProductStoreViewModel : ServiceManagerDelegate {
    
    private lazy var serviceManager = ServiceManager()
    var productModel : Bindable<[ProductStoreModel]?> = Bindable(nil)
    
    func requestProductStore(){
        serviceManager.delegate = self
        serviceManager.sendRequest(urlString: "https://fakestoreapi.com/products")
    }
    
    func serviceResponse(_ responseData: Data?, _ error: Error?) {
        if let modelResponse = self.parseJSONProductStore(ProductStoreData: responseData ?? Data()) {
            productModel.value = modelResponse
        }
    }
    
    func parseJSONProductStore(ProductStoreData: Data) -> [ProductStoreModel]? {
        let decoder = JSONDecoder()
        do{
            let decoderData = try decoder.decode([ProductStoreModel].self, from: ProductStoreData)
            return decoderData
        } catch {
            print(error)
            return nil
        }
    }
    
    func getNumberOfRows() -> Int {
        return productModel.value?.count ?? 0
    }
    
    func getProduct(at index:Int) -> ProductStoreModel? {
        return productModel.value?[index]
    }
}
