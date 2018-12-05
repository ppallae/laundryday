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
    
    @IBOutlet weak var brandNameTextView: UITextView!
    @IBOutlet weak var productTagNameTextView: UITextView!
    @IBOutlet weak var purchasedDate: UITextView!
    @IBOutlet weak var materialTextView: UITextView!
    
    @IBOutlet weak var drySymbol: UIImageView!
    @IBOutlet weak var washableSymbol: UIImageView!
    @IBOutlet weak var ironingSymbol: UIImageView!
    @IBOutlet weak var dryCleaningSymbol: UIImageView!
    @IBOutlet weak var bleachingSymbol: UIImageView!
    
    @IBOutlet weak var likeImageView: UIImageView!
    
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

        productNameLabel.isUserInteractionEnabled = false
        brandNameTextView.isUserInteractionEnabled = false
        productTagNameTextView.isUserInteractionEnabled = false
        purchasedDate.isUserInteractionEnabled = false
        materialTextView.isUserInteractionEnabled = false
        
    }
    
    
    func updateView() {
        self.productNameLabel.text = item?.productName
        self.brandNameTextView.text = item?.brandName
        self.productTagNameTextView.text = item?.productTagName
        self.purchasedDate.text = item?.purchasedDate
        self.materialTextView.text = item?.material
        
        self.drySymbol.image = UIImage(named: (item!.washSymbolList![0]))
        self.washableSymbol.image = UIImage(named: item!.washSymbolList![1])
        self.ironingSymbol.image = UIImage(named: item!.washSymbolList![2])
        self.dryCleaningSymbol.image = UIImage(named: item!.washSymbolList![3])
        self.bleachingSymbol.image = UIImage(named: item!.washSymbolList![4])
        
        if let photoUrlString = item!.productImgUrl {
            let photoUrl = URL(string: photoUrlString)
            self.productImageView.sd_setImage(with: photoUrl)
        }
        
        Api.Clothes.isLiked(itemId: item!.id!, completed: {value in
            if value {
                self.configureUnLike()
            } else {
                self.configureLike()
            }
        })
        
    }

    func loadItem(){
        Api.Clothes.observeClothes(withId: itemId!, completion: {clothes in
            self.item = clothes
            
        })
    }
    
    
    func configureLike() {
        let tapGestureForLikeImageView = UITapGestureRecognizer(target: self, action: #selector(self.likeAction))
        likeImageView.addGestureRecognizer(tapGestureForLikeImageView)
        likeImageView.isUserInteractionEnabled = true
        likeImageView.image = UIImage(named: "like")
    }
    func configureUnLike() {
        let tapGestureForUnLikeImageView = UITapGestureRecognizer(target: self, action: #selector(self.unLikeAction))
        likeImageView.addGestureRecognizer(tapGestureForUnLikeImageView)
        likeImageView.isUserInteractionEnabled = true
        likeImageView.image = UIImage(named: "likeSelected")
        
    }
    
    @objc func likeAction() {
        Api.Clothes.likeAction(withItem: item!.id!)
        configureUnLike()
    }
    @objc func unLikeAction(){
        Api.Clothes.unLikeAction(withItem: item!.id!)
        configureLike()
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
