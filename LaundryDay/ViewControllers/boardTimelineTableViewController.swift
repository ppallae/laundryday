//
//  boardTimelineTableViewController.swift
//  LaundryDay
//
//  Created by 정아 on 04/12/2018.
//  Copyright © 2018 MBP03. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
//import FirebaseStorageUI  //error "no such module:FIrebaseStorageUI"

class boardTimelineTableViewController: UITableViewController {
    //addNav
    //boardUploadController = boardUploadViewController()
    let postingBoard = UIStoryboard(name: "Board", bundle: nil)
    
    
    
    var ref:DatabaseReference?
    var storageRef:StorageReference?
    
    var posts = [Post]()                //테이블 뷰에 표시될 포스트들을 담는 배열
    var loadedPosts = [Post]()          //Firebase에서 로드된 포스트들
    
    //@IBOutlet weak var FooterLabel: UILabel!    //loading..메세지를 표시할 라벨
    
    @objc func posting() {
        let uploader = postingBoard.instantiateViewController(withIdentifier: "postingViewController")
        self.present(uploader, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        boardUploadController = storyBoard.instantiateInitialViewController(withIdentifier: "boardUploadViewController") as! boardUploadViewController
        boardUploadController.navigationItem.title = "업로드"
        */
        ref = Database.database().reference()    //Firebase Database 루트를 가리키는 레퍼런스
        storageRef = Storage.storage().reference()    //Firebase Storage 루트를 가리키는 레퍼런스
        
        
        
        
        loadPosts()     //Firebase에서 포스트들을 불러들임
        
        
        
        refreshControl = UIRefreshControl()         //최신글을 불러 들이기 위한 refreshControl
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(boardTimelineTableViewController.refresh), for: UIControlEvents.valueChanged) //refreshControl이 호출될 경우, boardTimelineViewController.refresh()가 호출되도록 한다.
        
        let btn = UIBarButtonItem(title: "추가하기", style: .plain, target: self, action: #selector(self.posting))
        self.navigationItem.rightBarButtonItem = btn

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boardTimelineCell", for: indexPath) as! boardTimelineTableViewCell
        let post = posts[indexPath.row]
        cell.TextLabel.text = post.text
        //cell.ImageView.image = post.imageView.image
        cell.titleLabel.text = post.title
        
        return cell
    }
    
    // MARK: -  Load posts
    func loadPosts(){
        var orderedQuery:DatabaseQuery?
        orderedQuery = ref?.child("posts").queryOrdered(byChild: "date")
        
        orderedQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            for anyDatum in snapshotData{
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                if let text = dicDatum["text"],
                    let title = dicDatum["title"],
                    let date = Int(dicDatum["date"]!){
                    let post = Post(title,text,date)
                    /*
                    //Get Image
                    let imageRef = self.storageRef?.child("\(snapshotDatum.key).jpg")
                    post.imageView.sd_setImage(with: imageRef!, placeholderImage: UIImage(), completed:{(image,error,cacheType,imageURL) in self.tableView.reloadData() })
                    */
                    self.loadedPosts += [post]
                }
            }
            
            self.posts += self.loadedPosts.prefix(g_NumPerOneLoad)
            self.tableView.reloadData()
        })
    }
    
    func loadFreshPosts(){
        var filteredQuery:DatabaseQuery?
        if let latestDate = self.posts.first?.date{
            filteredQuery = ref?.child("posts").queryOrdered(byChild: "date").queryStarting(atValue: "\(latestDate + 1)")
        }else{
            filteredQuery = ref?.child("posts").queryOrdered(byChild: "date").queryStarting(atValue: "\(0)")
        }
        
        filteredQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            var freshPostsChunk = [Post]()
            
            for anyDatum in snapshotData{
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                if let text = dicDatum["text"],
                    let title = dicDatum["title"],
                    let date = Int(dicDatum["date"]!){
                    let post = Post(title,text,date)
                    /*
                    //Get Image from URL
                    let imageRef = self.storageRef?.child("\(snapshotDatum.key).jpg")
                    post.imageView.*/
                    freshPostsChunk += [post]
                    
                    
                    
                }
            }
            self.loadedPosts.insert(contentsOf: freshPostsChunk, at: 0)
            self.posts.insert(contentsOf: freshPostsChunk, at: 0)
            self.tableView.reloadData()
        })
    }
    func loadPastPosts(){
        let pastPosts = self.loadedPosts.filter{$0.date < (self.posts.last?.date)!}
        let pastChunkPosts = pastPosts.prefix(g_NumPerOneLoad)
        
        if pastChunkPosts.count > 0{
            self.posts += pastChunkPosts
            sleep(1)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Reload Posts
    @objc func refresh(){
        print("refresh")
        self.loadFreshPosts()
        self.refreshControl?.endRefreshing()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height /*+ self.FooterLabel.frame.height*/ - contentYoffset
        if distanceFromBottom < height {
            print(" you reached end of the table")
            loadPastPosts()
        }
    }

}
