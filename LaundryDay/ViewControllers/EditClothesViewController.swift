//
//  EditClothesViewController.swift
//  LaundryDay
//
//  Created by CAUAD19 on 2018. 8. 1..
//  Copyright © 2018년 MBP03. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseStorage

class EditClothesViewController: UIViewController {
    
    var clothesId: String?
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UITextField!
    
    @IBOutlet weak var brandNameTextField: UITextField!
    @IBOutlet weak var productTagNameTextField: UITextField!
    @IBOutlet weak var purchasedDate: UITextField!
    @IBOutlet weak var materialTextField: UITextField!
    
    @IBOutlet weak var drySymbol: UIImageView!
    @IBOutlet weak var washableSymbol: UIImageView!
    @IBOutlet weak var ironingSymbol: UIImageView!
    @IBOutlet weak var dryCleaningSymbol: UIImageView!
    @IBOutlet weak var bleachingSymbol: UIImageView!
    
    
    var item: Clothes? {
        didSet {
            updateView()
        }
    }
    
    var selectedImage: UIImage?
    var selectedImageView: UIImageView?
    var symbolList : [String]!
    var symbolListNum = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        loadItem()
        
        handleTextField()
        
        
        //사진선택
        let tapGesture =  UITapGestureRecognizer(target: self, action: #selector(self.handleSelectImage))
        productImageView.addGestureRecognizer(tapGesture)
        productImageView.isUserInteractionEnabled = true
        
        //세탁기호선택
        addtapGestureInSymbols()

       
    }
    
    func updateView() {
        self.productNameLabel.text = item?.productName
        self.brandNameTextField.text = item?.brandName
        self.productTagNameTextField.text = item?.productTagName
        self.purchasedDate.text = item?.purchasedDate
        self.materialTextField.text = item?.material
        
        self.drySymbol.image = UIImage(named: (item!.washSymbolList![0]))
        self.washableSymbol.image = UIImage(named: item!.washSymbolList![1])
        self.ironingSymbol.image = UIImage(named: item!.washSymbolList![2])
        self.dryCleaningSymbol.image = UIImage(named: item!.washSymbolList![3])
        self.bleachingSymbol.image = UIImage(named: item!.washSymbolList![4])
        
        symbolList = item?.washSymbolList
        
        if let photoUrlString = item!.productImgUrl {
            let photoUrl = URL(string: photoUrlString)
            self.productImageView.sd_setImage(with: photoUrl)
        }
    }
    
    func loadItem(){
        Api.Clothes.observeClothes(withId: clothesId!, completion: {clothes in
            self.item = clothes
            
        })
    }
    
    
    
    func addtapGestureInSymbols() {
        let tapGestureSymbolDry =  UITapGestureRecognizer(target: self, action: #selector(chooseWashingSymbols(sender:)))
        let tapGestureSymbolWash =  UITapGestureRecognizer(target: self, action: #selector(chooseWashingSymbols(sender:)))
        let tapGestureSymbolIron =  UITapGestureRecognizer(target: self, action: #selector(chooseWashingSymbols(sender:)))
        let tapGestureSymbolClean =  UITapGestureRecognizer(target: self, action: #selector(chooseWashingSymbols(sender:)))
        let tapGestureSymbolBleach =  UITapGestureRecognizer(target: self, action: #selector(chooseWashingSymbols(sender:)))
        
        
        drySymbol.addGestureRecognizer(tapGestureSymbolDry)
        drySymbol.isUserInteractionEnabled = true
        washableSymbol.addGestureRecognizer(tapGestureSymbolWash)
        washableSymbol.isUserInteractionEnabled = true
        ironingSymbol.addGestureRecognizer(tapGestureSymbolIron)
        ironingSymbol.isUserInteractionEnabled = true
        dryCleaningSymbol.addGestureRecognizer(tapGestureSymbolClean)
        dryCleaningSymbol.isUserInteractionEnabled = true
        bleachingSymbol.addGestureRecognizer(tapGestureSymbolBleach)
        bleachingSymbol.isUserInteractionEnabled = true
        
    }
    
    @objc func handleSelectImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "카메라", style: .default, handler: {(action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                pickerController.sourceType = .camera
                self.present(pickerController,animated: true, completion: nil)
            } else {
                print("카메라가 비활성화 되어있습니다.")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "앨범", style: .default, handler: {(action: UIAlertAction) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController,animated: true,completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(actionSheet,animated: true,completion: nil)
        
    }
    
    @objc func chooseWashingSymbols(sender: UITapGestureRecognizer) {
        let gesture = sender.view
        let tag = gesture?.tag
        let theme: String?
        let list: [String:String]?
        let vc = storyboard?.instantiateViewController(withIdentifier: "WashingSymbolViewController") as? WashingSymbolViewController
        vc?.delegate = self
        switch tag {
        case 11:
            theme = "dry"
            list = Api.WashSymbols.drySymbol
            symbolListNum = 0
            selectedImageView = gesture as? UIImageView
        case 12:
            theme = "washable"
            list = Api.WashSymbols.washableSymbol
            symbolListNum = 1
            selectedImageView = gesture as? UIImageView
        case 13:
            theme = "ironing"
            list = Api.WashSymbols.ironingSymbol
            symbolListNum = 2
            selectedImageView = gesture as? UIImageView
        case 14:
            theme = "dryCleaning"
            list = Api.WashSymbols.dryCleaningSymbol
            symbolListNum = 3
            selectedImageView = gesture as? UIImageView
        case 15:
            theme = "bleaching"
            list = Api.WashSymbols.bleachingSymbol
            symbolListNum = 4
            selectedImageView = gesture as? UIImageView
        default:
            theme = "none"
            list = ["":""]
            selectedImageView = nil
        }
        vc?.theme = theme
        vc?.list = list
        addChildViewController(vc!)
        view.addSubview((vc?.view)!)
        vc?.didMove(toParentViewController: self)
        vc?.view.frame.size.width = 300
        vc?.view.frame.size.height = 500
        vc?.view.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        vc?.view.dropShadow()
        
    }
    
    
    

    @IBOutlet weak var uploadBtn: UIButton!
    
    @IBAction func uploadButton_TUI(_ sender: Any) {
        ProgressHUD.show("Waiting")
        if selectedImage != nil {
            if let productImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(productImg, 0.1) {
                HelperService.updateClothesImage(data: imageData, clothesID: clothesId!, onSuccess: {
                    HelperService.sendClothesText(clothesID: self.clothesId!, productName: self.productNameLabel.text!, brandName: self.brandNameTextField.text!, productTagName: self.productTagNameTextField.text!, purchasedDate: self.purchasedDate.text!, material: self.materialTextField.text!, washSymbolList: self.symbolList, onSuccess: {
                            
                            ProgressHUD.showSuccess()
                            self.dismiss(animated: true, completion: nil)
                        })
                    })
            }
        } else {
            
            HelperService.sendClothesText(clothesID: self.clothesId!, productName: self.productNameLabel.text!, brandName: self.brandNameTextField.text!, productTagName: self.productTagNameTextField.text!, purchasedDate: self.purchasedDate.text!, material: self.materialTextField.text!, washSymbolList: self.symbolList, onSuccess: {
                
                ProgressHUD.showSuccess()
                self.dismiss(animated: true, completion: nil)
            })
            }
            
        }
        
        
    
    
    
    
    func handleTextField() {
        productNameLabel.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        brandNameTextField.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        productTagNameTextField.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        purchasedDate.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        materialTextField.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        
        
    }
    
    @objc func textFieldChanged() {
        guard  let productName = productNameLabel.text, !productName.isEmpty , let password = brandNameTextField.text, !password.isEmpty, let name = purchasedDate.text, !name.isEmpty, let contact = productTagNameTextField.text, !contact.isEmpty, let material = materialTextField.text, !material.isEmpty  else {
            uploadBtn.isEnabled = false
            uploadBtn.backgroundColor = UIColor.lightGray
            return
        }
        uploadBtn.isEnabled = true
        uploadBtn.backgroundColor = UIColor(red: 72/255, green: 199/255, blue: 149/255, alpha: 1)
        
    }
    

}



extension EditClothesViewController: WashingSymbolViewControllerDelegate {
    func selectedValue(value: String) {
        let imageName = value
        selectedImageView?.image = UIImage(named: imageName)
        selectedImageView?.reloadInputViews()
        symbolList[symbolListNum] = imageName
        
    }
}

extension EditClothesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            productImageView.image = image
            
        }
        dismiss(animated: true, completion: nil)
    }
}

