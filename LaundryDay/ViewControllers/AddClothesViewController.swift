//
//  addClothesViewController.swift
//  LaundryDay
//
//  Created by MBP03 on 2018. 4. 27..
//  Copyright © 2018년 MBP03. All rights reserved.
//

import UIKit
import ProgressHUD


class AddClothesViewController: UIViewController {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameTextField: UITextField!
    
    @IBOutlet weak var brandNameTextField: UITextField!
    @IBOutlet weak var productTagNameTextField: UITextField!
    @IBOutlet weak var purchasedDate: UITextField!
    @IBOutlet weak var materialTextField: UITextField!
    
    @IBOutlet weak var drySymbol: UIImageView!
    @IBOutlet weak var washableSymbol: UIImageView!
    @IBOutlet weak var ironingSymbol: UIImageView!
    @IBOutlet weak var dryCleaningSymbol: UIImageView!
    @IBOutlet weak var bleachingSymbol: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    var selectedImage: UIImage?
    var selectedImageView: UIImageView?
    var symbolList = ["dry_none","washable_none","ironing_none","drycleaning_none","bleaching_none"]
    var symbolListNum = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //사진선택
        let tapGesture =  UITapGestureRecognizer(target: self, action: #selector(self.handleSelectImage))
        productImageView.addGestureRecognizer(tapGesture)
        productImageView.isUserInteractionEnabled = true
        
        //세탁기호선택
        addtapGestureInSymbols()
        
        //이름입력해야 추가하기버튼 활성화
        uploadButton.isEnabled = false
        uploadButton.backgroundColor = UIColor.lightGray
        uploadButton.setTitleColor(.white, for: .disabled)
        uploadButton.setTitleColor(.black, for: .normal)
        handleTextField()
        
        
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
    
    
    
    
    
    @IBAction func uploadButton_TUI(_ sender: Any) {
        ProgressHUD.show("Waiting")
        if let productImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(productImg, 0.1) {
            HelperService.updataToServer(data: imageData, productName: productNameTextField.text!, brandName: brandNameTextField.text!, productTagName: productTagNameTextField.text!, purchasedDate: purchasedDate.text!, material: materialTextField.text! ,washSymbolList:symbolList, onSuccess: {
//                if (self.delegate != nil) {
//                    self.delegate?.changeClosetIdToAll(id: "All")
//                }
//
//                ClosetListViewController.removeViewController(childVC: self)
                TimeDelay.runThisAfterDelay(seconds: 0.5){
                    self.symbolList = ["dry_none","washable_none","ironing_none","drycleaning_none","bleaching_none"]
                    self.dismiss(animated: true, completion: nil)
                }
                //self.dismiss(animated: true, completion: nil)
                })
            
        } else {
            ProgressHUD.showError("사진을 선택해주세요.")
        }
    
        
    }
    
    
    func handleTextField() {
        productNameTextField.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        brandNameTextField.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        productTagNameTextField.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        purchasedDate.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        materialTextField.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        
        
    }
    
    @objc func textFieldChanged() {
        guard  let productName = productNameTextField.text, !productName.isEmpty , let password = brandNameTextField.text, !password.isEmpty, let name = purchasedDate.text, !name.isEmpty, let contact = productTagNameTextField.text, !contact.isEmpty, let material = materialTextField.text, !material.isEmpty  else {
            uploadButton.isEnabled = false
            uploadButton.backgroundColor = UIColor.lightGray
            return
        }
        uploadButton.isEnabled = true
        uploadButton.backgroundColor = UIColor(red: 72/255, green: 199/255, blue: 149/255, alpha: 1)
        
    }
    
    
    
    //추가하기 창 취소
    @IBAction func cancelButton_TUI(_ sender: Any) {
        //ClosetListViewController.removeViewController(childVC: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    var delegate: AddClothesViewControllerDelegate?
    

    

}
@objc protocol AddClothesViewControllerDelegate {
    @objc optional func changeClosetIdToAll(id: String)
}

extension AddClothesViewController: WashingSymbolViewControllerDelegate {
    func selectedValue(value: String) {
        let imageName = value
        selectedImageView?.image = UIImage(named: imageName)
        selectedImageView?.reloadInputViews()
        symbolList[symbolListNum] = imageName
        
    }
}

extension AddClothesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            productImageView.image = image
            descriptionLabel.text = ""
        }
        dismiss(animated: true, completion: nil)
    }
}


extension UIView {
    
    //뷰에 새도우 넣기
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}



