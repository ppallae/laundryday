//
//  DetailViewController.swift
//  LaundryDay
//
//  Created by CAUADC on 2018. 6. 1..
//  Copyright © 2018년 MBP03. All rights reserved.
//

import UIKit
import SDWebImage

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    var instantVC: UIViewController?
    var uid: String?
    var itemId: String?
    var item: Clothes? {
        didSet {
            updateView()
        }
    }
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        loadItem()
        addTapGesture()
        
        //var rightButton = UIBarButtonItem(image: UIImage(named: "more.png"), style: .plain, target: self, action: #selector(self.singleTapAction))
        //self.navigationItem.rightBarButtonItem = rightButton

        
    }
    
    
    func updateView() {
        self.productNameLabel.text = item?.productName
        if let photoUrlString = item!.productImgUrl {
            let photoUrl = URL(string: photoUrlString)
            self.productImageView.sd_setImage(with: photoUrl)
        }
    }

    func loadItem(){
        Api.Clothes.observeClothes(withId: itemId!, completion: {clothes in
            self.item = clothes
            
        })
    }
    func addTapGesture() {
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTapAction))
//        singleTapRecognizer.isEnabled = true
//        singleTapRecognizer.numberOfTapsRequired = 1
//        singleTapRecognizer.cancelsTouchesInView = false
        detailView.addGestureRecognizer(singleTapRecognizer)
        
    }
    func addDismissTapGesture() {
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissSingleTapAction))
        detailView.addGestureRecognizer(singleTapRecognizer)
    }
    @objc func singleTapAction() {
        editingView()
        addDismissTapGesture()
    }
    @objc func dismissSingleTapAction() {
        hideContentController(content: self.instantVC!)
        addTapGesture()
    }
    
    func editingView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailEditingViewController") as? DetailEditingViewController
        //vc?.delegate = self
        vc?.clothesId = self.itemId
        vc?.imageString = self.item?.imageString
        vc?.uid = self.uid
        
        self.instantVC = vc
        displayChildViewController(vc: vc!)
        view.addSubview((vc?.view)!)
        vc?.didMove(toParentViewController: self)
        vc?.view.frame = CGRect(x: 0, y: self.view.frame.height - 70 , width: self.view.frame.width, height: 100)
        // iphone X 일 경우 y 이상하다
    }
    func displayChildViewController(vc: UIViewController) {
        addChildViewController(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    
    
    func hideContentController(content: UIViewController) {
        content.willMove(toParentViewController: nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
    


}
