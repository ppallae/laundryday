//
//  HelperService.swift
//  LaundryDay
//
//  Created by MBP03 on 2018. 5. 22..
//  Copyright © 2018년 MBP03. All rights reserved.
//

import Foundation
import FirebaseStorage
import ProgressHUD

class HelperService {
    //MARK: -add clothes
    static func updataToServer(data: Data, productName: String,brandName: String, productTagName: String, purchasedDate: String, material: String, washSymbolList:[String], onSuccess: @escaping () -> Void) {
        
        let imageString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STROAGE_ROOT_REF).child("items").child(imageString)
        storageRef.putData(data, metadata: nil) { (metadata,error) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            let productImgURL = metadata?.downloadURL()?.absoluteString
            self.sendDataToDatabase(imageString: imageString,productImgURL: productImgURL!, productName: productName, brandName: brandName,productTagName:productTagName,purchasedDate:purchasedDate, material: material, washSymbolList: washSymbolList, onSuccess: onSuccess)

        }
    }
    static func sendDataToDatabase(imageString:String,productImgURL:String, productName:String, brandName: String, productTagName: String, purchasedDate: String, material:String, washSymbolList: [String], onSuccess: @escaping ()->Void) {
        let newClothesID = Api.Clothes.REF_ITEMS.childByAutoId().key
        let newClothesRef = Api.Clothes.REF_ITEMS.child(newClothesID)
        guard let currentUser = Api.User.CURRENT_USER else{
            return
    }
        let currentUserID = currentUser.uid
        newClothesRef.setValue(["imageString": imageString, "productImgUrl":productImgURL, "productName": productName, "brandName": brandName, "productTagName": productTagName, "purchasedDate": purchasedDate, "material": material, "washSymbolList": washSymbolList, "uid": currentUserID /*, "isLiked": false*/], withCompletionBlock: {(error, ref) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            
            let myClothesRef = Api.MyItems.REF_MYITEMS.child(currentUserID).child(newClothesID)
            myClothesRef.setValue(true, withCompletionBlock: {(error,ref) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
            })

            ProgressHUD.showSuccess("Success")
            onSuccess()
        })
        
    }
    
    
    
    //MARK: -add closet
    static func sendClosetDataToDatabase(closetName: String,items: [String], onSuccess: @escaping ()->Void) {
        let newClosetID = Api.Closets.REF_CLOSETS.childByAutoId().key
        let newClosetRef = Api.Closets.REF_CLOSETS.child(newClosetID)
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        let currentUserID = currentUser.uid
        newClosetRef.setValue(["closetName": closetName, "uid": currentUserID], withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            let itemsRef = newClosetRef.child("items")
            for itemId in items {
                itemsRef.child(itemId).setValue(true, withCompletionBlock: {(error,ref) in
                    if error != nil {
                        ProgressHUD.showError(error?.localizedDescription)
                        return
                    }
                    Api.Clothes.REF_ITEMS.child(itemId).child("closetList").child(newClosetID).setValue(true, withCompletionBlock: {(error, ref) in
                        if error != nil {
                            ProgressHUD.showError(error?.localizedDescription)
                            return
                        }
                    })
                })
                
            }
            let myClosetsRef = Api.MyClosets.REF_MYCLOSETS.child(currentUserID).child(newClosetID)
            myClosetsRef.setValue(true, withCompletionBlock: { (error,ref) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
            })
            ProgressHUD.showSuccess("Success")
            onSuccess()
        })
    }
    
   
    
    
}
