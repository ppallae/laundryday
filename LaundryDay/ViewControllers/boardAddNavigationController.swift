//
//  boardAddNavigationController.swift
//  LaundryDay
//
//  Created by 정아 on 04/12/2018.
//  Copyright © 2018 MBP03. All rights reserved.
//

import UIKit

class boardAddNavigationController: UINavigationController {
    var boardUploadController = boardUploadViewController()
    let storyBoard = UIStoryboard(name: "Board", bundle: nil) //맞게 가리켰나
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //boardUploadController = storyBoard.instantiateInitialViewController(withIdentifier: "boardUploadViewController") as! boardUploadViewController
        boardUploadController.navigationItem.title = "업로드"
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isNavigationBarHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
