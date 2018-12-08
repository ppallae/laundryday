//
//  boardUploadViewController.swift
//  LaundryDay
//
//  Created by 정아 on 04/12/2018.
//  Copyright © 2018 MBP03. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class boardUploadViewController: UIViewController, UITextViewDelegate {
    
    //@IBOutlet weak var ImageView: UIImageView! //이전 탭에서 선택한 이미지를 보여주는 imageView
    @IBOutlet weak var TextView: UITextView! //사용자가 글을 작성하는 textview
    @IBOutlet weak var TitleView: UITextView! //사용자가 제목을 작성하는 textview
    //@IBOutlet weak var boardCompleteButton: UIButton! //글 작성 완료버튼
    
    @IBAction func goPosting(_Sender: AnyObject) {
        uploadPost()
    }
    
    @IBAction func cancelButton_TUI(_ sender: Any) {
        //ClosetListViewController.removeViewController(childVC: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    //var image = UIImage() //AddNavigationController에서 넘기는 image를 받을 변수
    let placeHolder = "개인 정보를 요구하는 행위는 금지됩니다." //아무 글짜도 없을 경우 보여주는 것
    let titleBeginner = "제목을 입력해주세요"
    
    var ref: DatabaseReference? //우리가 사용할 Firebase Database
    var storageRef:StorageReference? //우리가 사용할 Firebase Storage 레퍼런스
    
    var currentUserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference() //Firebase Database 루트를 가리키는 레퍼런스
        storageRef = Storage.storage().reference() //Firebase Storage 루트를 가리키는 레퍼런스
        
        self.TextView.delegate = self
        textViewDidEndEditing(TextView)
        //self.TitleView.delegate = self
        //titleViewDidEndEditing(TitleView)
        
        var tapDismiss = UITapGestureRecognizer(target:self,action:"dismissKeyboard")
        self.view.addGestureRecognizer(tapDismiss)
        
        
        TitleView.text = titleBeginner
        TextView.text = placeHolder
        
        Api.User.observeCurrentUser(completion: {user in
            self.currentUserName = user.userName
        })
 
        
        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(uploadPost))
        //self.navigationItem.rightBarButtonItem = addButton
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - TextView PlaceHolder
    func dismissKeyboard(){
        TextView.resignFirstResponder()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == ""){
            textView.text = placeHolder
            textView.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
    }
    
    func titleViewDidEndEditing(_ titleView: UITextView) {
        if(titleView.text == ""){
            titleView.text = titleBeginner
            titleView.textColor = UIColor.lightGray
        }
        titleView.resignFirstResponder() //
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == placeHolder){
            textView.text = ""
            textView.textColor = UIColor.black
        }
        textView.becomeFirstResponder()
    }
    
    func titleViewDidBeginEditing(_ titleView: UITextView) {
        if(titleView.text == titleBeginner){
            titleView.text = ""
            titleView.textColor = UIColor.black
        }
        titleView.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.TextView.isEditable = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.TextView.isEditable = false
    }
   
    //MARK: - ImageView
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.isNavigationBarHidden = false //UploadViewController가 보여지는 경우에는 NavigationBar표시
        //self.ImageView.image = image //AddNavigationController가 넘겨준 이미지를 ImageView에 표시
    }
    override func viewWillDisappear(_ animated: Bool) {
        //self.navigationController?.isNavigationBarHidden = true //UploadViewController가 사라지면, Navigation Bar를 숨긴다.
    }
    @objc func uploadPost(){
        var curRef = self.ref?.child("posts").childByAutoId() //Database 루트 아래 posts 아래 새로운 게시글을 참조한다.
        if (self.TextView.text != placeHolder) { //PlaceHolder 유무에 따른 글 업로드
            curRef?.child("text").setValue(self.TextView.text) //PlaceHolder와 같을 때 새로운 게시글의 text를 self.TextView.text로 지정
            curRef?.child("title").setValue(self.TitleView.text)
            curRef?.child("userName").setValue(self.currentUserName)
        }else{
            curRef?.child("text").setValue("") //PlaceHolder와 같을 때 새로운 게시글의 text를 빈 텍스트로 지정.
            curRef?.child("title").setValue("")
            curRef?.child("userName").setValue(self.currentUserName)
        }/*
        if self.TitleView.text != titleBeginner {
            curRef?.child("title").setValue(self.TitleView.text)
        }else{
            curRef?.child("title").setValue("")
        }*/
        
        self.TextView.text = "" //한번 업로드 한 경우 다음 차례에 uploadViewController가 표시될 때 빈 텍스트만 보이도록 한다.
        self.TitleView.text = ""
        textViewDidEndEditing(TextView)
        //titleViewDidEndEditing(TitleView)
        
        
        let date = Date()
        let IntValueOfDate = Int(date.timeIntervalSince1970) //1970년대 이후부터 현재까지 흐른 시간을 숫자 하나로 얻음
        curRef?.child("date").setValue("\(IntValueOfDate)") //새로운 게시글의 datefmf IntValueOfDate로 업로드
        
        self.dismiss(animated: true, completion: nil)
        /*
        let imageRef = storageRef?.child((curRef?.key)!+".jpg") //Firebase Storage 루트에 "curRef?.key+.jpg"에 해당하는 참조를 만든다
        
        guard var uploadData = UIImageJPEGRepresentation(self.image, 0.1) else{
            return
        }
        imageRef?.putData(uploadData, metadata: nil, completion:{ metadata, error in
            if let error = error {
                // 에러 발생
            } else {
                // Metadata는 size, content-type, download URL과 같은 컨텐트의 메타데이터를 가진다
            }
        }) */
        
    }

}
