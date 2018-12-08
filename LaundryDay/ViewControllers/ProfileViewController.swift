//
//  ProfileViewController.swift
//  LaundryDay
//
//  Created by MBP03 on 2018. 4. 14..
//  Copyright © 2018년 MBP03. All rights reserved.
//

import UIKit
import ProgressHUD

class ProfileViewController: UIViewController{
    //정아 0729
    
    
    @IBOutlet weak var userInfoView : UIView!
    @IBOutlet weak var userImage : UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var myPostsCount : UILabel!
    @IBOutlet weak var myCommentsCount : UILabel!
    @IBOutlet weak var myPublicClosetCount : UILabel!
    @IBOutlet weak var myFriendsCount: UILabel!
    @IBOutlet weak var searchTheLaundryShopButton: UIButton!
    
    
    var LabelName = String()
    
    var currentUser: UserInfo?{
        didSet{
            updateView()
        }
    }
    
    func updateView() {
        self.nameLabel.text = currentUser?.userName
        if let photoUrlString = currentUser?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            self.userImage.sd_setImage(with: photoUrl)
        }
    }
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        //userInfoView.dataSource = self
        
        
        navigationController?.navigationBar.setBackgroundImage(UIColor(red: 72/255, green: 199/255, blue: 149/255, alpha: 1).as1ptImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = false
        
        //네비게이션 컬러
        //self.navigationController?.navigationBar.backgroundColor = UIColor(red: 72/255, green: 299/255, blue: 149/255, alpha: 1)
        fetchUser()
    }
    
    func fetchUser(){
        Api.User.observeCurrentUser{(user) in
            self.currentUser = user
            //self.userInfoView.reloadData()
        }
    }
    
    //여기까지 정아 0729 프로필헤더뷰

 

    @IBAction func logOutButton_TUI(_ sender: Any) {
       
        AuthService.logout(onSuccess: {let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)}, onError: {errorMessage in
                ProgressHUD.showError(errorMessage)
        })
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


