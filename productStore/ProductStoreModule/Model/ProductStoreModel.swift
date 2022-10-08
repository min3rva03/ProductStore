//
//  productStoreModel.swift
//  productStore
//
//  Created by Minerva Nolasco Espino on 06/10/22.
//

import Foundation

public struct ProductStoreModel : Codable {
    
    public var category : String
    public var title : String
    public var price : Double
    public var image : String
}
