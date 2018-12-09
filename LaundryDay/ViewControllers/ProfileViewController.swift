//
//  ProfileViewController.swift
//  LaundryDay
//
//  Created by MBP03 on 2018. 4. 14..
//  Copyright © 2018년 MBP03. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

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
    
    @IBOutlet weak var tabelview: UITableView!
    
    var LabelName = String()
    
    var ref:DatabaseReference?
    var storageRef:StorageReference?
    
    var posts = [Post]()                //테이블 뷰에 표시될 포스트들을 담는 배열
    var loadedPosts = [Post]()
    var userEmail: String?
    
    
    var currentUser: UserInfo?{
        didSet{
            updateView()
        }
    }
    
    func updateView() {
        self.nameLabel.text = (currentUser?.userName)! + "(" + self.userEmail! + ")"
        if let photoUrlString = currentUser?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            self.userImage.sd_setImage(with: photoUrl)
        }
    }
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        //userInfoView.dataSource = self
        
        tabelview.dataSource = self
        tabelview.delegate = self
        navigationController?.navigationBar.setBackgroundImage(UIColor(red: 72/255, green: 199/255, blue: 149/255, alpha: 1).as1ptImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = false
        
        //네비게이션 컬러
        //self.navigationController?.navigationBar.backgroundColor = UIColor(red: 72/255, green: 299/255, blue: 149/255, alpha: 1)
        fetchUser()
        
        fetchMyPosts()
        
        
       
        
    }
    
    func fetchMyPosts() {
        let user = Auth.auth().currentUser
        
        let myPostsRef = Database.database().reference().child("myPosts")
        //추가된 포스트 리로드
        
        myPostsRef.child(user!.uid).observe(.childAdded, with: {snapshot in
            
            let postId = snapshot.key
            var orderedQuery:DatabaseQuery?
            let postRef = Database.database().reference().child("posts").child(postId)
            postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                
            
                    let dicDatum = snapshot.value as! [String:String]
                    if let text = dicDatum["text"],
                        let title = dicDatum["title"],
                        let userName = dicDatum["userName"],
                        let date = Int(dicDatum["date"]!){
                        let post = Post(title,text,date,userName)
                        /*
                         //Get Image
                         let imageRef = self.storageRef?.child("\(snapshotDatum.key).jpg")
                         post.imageView.sd_setImage(with: imageRef!, placeholderImage: UIImage(), completed:{(image,error,cacheType,imageURL) in self.tableView.reloadData() })
                         */
                        self.posts.insert(post, at: 0)
                        self.tabelview.reloadData()
                        
                    }
                
                
            })
        })
        
    }
    
    
    
    
    
    func fetchUser(){
        Api.User.observeCurrentUser{(user) in
            self.currentUser = user
            //self.userInfoView.reloadData()
        }
        self.userEmail = Auth.auth().currentUser?.email
    }
    
    //여기까지 정아 0729 프로필헤더뷰

 

    @IBAction func logOutButton_TUI(_ sender: Any) {
       
        AuthService.logout(onSuccess: {let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)}, onError: {errorMessage in
                ProgressHUD.showError(errorMessage)
        })
    }
    
        
    
    


}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let subview = UIView()
        subview.backgroundColor = .lightGray
        subview.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        let listLabel = UILabel()
        listLabel.text = "내가 쓴 글"
        listLabel.textAlignment = .center
        listLabel.textColor = .white
        listLabel.font = UIFont.systemFont(ofSize: 17)

        subview.addSubview(listLabel)
        listLabel.translatesAutoresizingMaskIntoConstraints = false
        listLabel.heightAnchor.constraint(equalToConstant: 200).isActive = true
        listLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        listLabel.leadingAnchor.constraint(equalTo: listLabel.superview!.leadingAnchor).isActive = true
        listLabel.centerYAnchor.constraint(equalTo: listLabel.superview!.centerYAnchor).isActive = true


        return subview
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPostsTableViewCell", for: indexPath) as! MyPostsTableViewCell
        let post = posts[indexPath.row]
        cell.post = post
        return cell
    }
    
    
    
    
    
}


