//
//  ProductTableViewCell.swift
//  productStore
//
//  Created by Minerva Nolasco Espino on 06/10/22.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageCell: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
