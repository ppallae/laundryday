//
//  boardAddNavigationController.swift
//  LaundryDay
//
//  Created by 정아 on 04/12/2018.
//  Copyright © 2018 MBP03. All rights reserved.
//

import UIKit
//import Fusuma

class boardAddNavigationController: UINavigationController/*,FusumaDelegate*/ {
   
    //let fusuma = FusumaViewController() //이미지 선택을 위한 Fusuma컨트롤러
    var uploadController = boardUploadViewController() //텍스트 입력, 게시글 업로드를 위한 컨트롤러
    
    //let storyBoard = UIStoryboard(name: "Main", bundle: nil) //Main.storyboard를 가리킴
    
    override func viewDidLoad() {
        super.viewDidLoad() /*
        fusumaTintColor = UIColor.black
        fusumaBaseTintColor = UIColor.black
        fusumaBackgroundColor = UIColor.white
        
        fusuma.delegate = self
        fusuma.hasVideo = false
        fusuma.cropHeightRatio = 0.6 // Height-to-width ratio.
        fusuma.allowMultipleSelection = false
        fusuma.defaultMode = .library
        
        fusuma.hidesBottomBarWhenPushed = true
        */
        uploadController = storyBoard.instantiateViewController(withIdentifier: "boardUploadViewController") as! boardUploadViewController
        uploadController.navigationItem.title = "업로드"
    
        //self.pushViewController(fusuma, animated: false)
    }
/*
    override func viewWillAppear(_ animated: Bool) {
        self.isNavigationBarHidden = true
        self.popToViewController(fusuma, animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        uploadController.image = image
        self.pushViewController(uploadController, animated: true)
    }
    func fusumaWillClosed() {
        self.tabBarController?.selectedIndex = 0
    }
 
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage, source: FusumaMode) {
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
    }
    
    // Return selected images when you allow to select multiple photos.
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
    }
    
    // Return an image and the detailed information.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {
    }
 */

}
