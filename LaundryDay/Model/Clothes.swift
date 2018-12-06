//
//  Clothes.swift
//  LaundryDay
//
//  Created by MBP03 on 2018. 5. 17..
//  Copyright © 2018년 MBP03. All rights reserved.
//

import Foundation

class Clothes  {
    var productImgUrl: String?
    var productName: String?
    var brandName: String?
    var productTagName: String?
    var purchasedDate: String?
    var material: String?
    
    var washSymbolList: [String]?
    
    var uid: String?
    var id: String?
    var isLiked: Bool?
    var imageString: String?
    //var isSelected: Bool?
    @IBOutlet weak var descriptionLabel: UILabel!
    
}
extension Clothes {
    static func transformClothes(dict: [String:Any], key:String) -> Clothes {
        let clothes = Clothes()
        clothes.productImgUrl = dict["productImgUrl"] as? String
        clothes.productName = dict["productName"] as? String
        clothes.brandName = dict["brandName"] as? String
        clothes.productTagName = dict["brandName"] as? String
        clothes.purchasedDate = dict["brandName"] as? String
        clothes.material = dict["material"] as? String
        
        clothes.washSymbolList = dict["washSymbolList"] as? [String]
        
        clothes.uid = dict["uid"] as? String
        clothes.id = key
        clothes.imageString = dict["imageString"] as? String
        clothes.isLiked = dict["isLiked"] as? Bool
        //clothes.isSelected = false
        return clothes
    }
}

