//
//  ClosetViewController.swift
//  LaundryDay
//
//  Created by MBP03 on 2018. 4. 14..
//  Copyright © 2018년 MBP03. All rights reserved.
//

import UIKit
import SDWebImage

class ClosetViewController: UIViewController {

    @IBOutlet weak var leadingViewConstraint: NSLayoutConstraint!
    var closetListShowing = false
    
    @IBOutlet weak var noItemView: UIView!
    
    @IBOutlet weak var closetListView: UIView!
    @IBOutlet weak var closetListButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addClothesBtn: UIButton!
    @IBOutlet weak var likeListBtn: UIButton!
    var user: UserInfo!
    var items = [Clothes]()
    var closetId: String = "All"
    var isShowingLikeItems = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //네비게이션바 색조정
        navigationController?.navigationBar.setBackgroundImage(UIColor(red: 72/255, green: 199/255, blue: 149/255, alpha: 1).as1ptImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        
        //collectionview 옆으로 띄우기
        collectionView.contentInset.right = 20
        collectionView.contentInset.left = 20
        collectionView.contentInset.top = 15
        
        //collectionview 데이터 연결
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchUser()
        checkClosetId(closetID: closetId)
        
        //옷 하나도 없을때 이미지뷰
        noItemView.isHidden = true
        
        
        collectionView.isUserInteractionEnabled = true
        self.collectionView.layer.cornerRadius = 2
        configureLikeList()
        
        
        print("viewDidLoad")

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
        reloadData()
    }

    
    
    func checkClosetId(closetID: String) {
        print("checkClosetId 실행")
        print(closetID)
        self.items.removeAll()
        if closetID == "All" {
            fetchMyItems()
            addClothesBtn.setTitleColor(.blue, for: .normal)
            addClothesBtn.isUserInteractionEnabled = true
        } else {
            fetchItemsInCloset()
            addClothesBtn.setTitleColor(.lightGray, for: .normal)
            addClothesBtn.isUserInteractionEnabled = false
        }
    }
    
    func fetchUser() {
        Api.User.observeCurrentUser(completion: {user in
            self.user = user
            self.reloadData()
        })
        print("fetchUser 실행")
    }
    
    func fetchMyItems() {
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        Api.MyItems.REF_MYITEMS.child(currentUser.uid).observe(.childAdded, with: {snapshot in
            Api.Clothes.observeClothes(withId: snapshot.key, completion: {clothes in
                if self.isShowingLikeItems {
                    if clothes.isLiked != nil && clothes.isLiked! {
                        self.items.insert(clothes, at: 0)
                        self.reloadData()
                    } else {
                        print("no items")
                        self.reloadData()
                    }
                } else {
                    self.items.insert(clothes, at: 0)
                    self.reloadData()
                }

            })
        })
        Api.MyItems.REF_MYITEMS.child(currentUser.uid).observe(.childRemoved, with: {snap in
            let snapId = snap.key
            if let index = self.items.index(where: {(item)-> Bool in item.id == snapId}) {
                self.items.remove(at: index)
                self.reloadData()
            }
        })
    }
    //아이템 비어있을때 이미지 보여줄 것
    func reloadData() {
        if self.items.count == 0 {
            noItemView.isHidden = false
            
        } else {
            noItemView.isHidden = true
            collectionView.reloadData()
        }
    }
    
    
    func fetchItemsInCloset() {

        Api.Closets.REF_CLOSETS.child(closetId).child("items").observe(.childAdded, with: { snapshot in
            Api.Clothes.observeClothes(withId: snapshot.key, completion: {clothes in
                if self.isShowingLikeItems {
                    if clothes.isLiked != nil && clothes.isLiked! {
                        self.items.insert(clothes, at: 0)
                        self.collectionView.reloadData()
                    } else {
                        print("no items")
                        self.collectionView.reloadData()
                    }
                } else {
                    self.items.insert(clothes, at: 0)
                    self.collectionView.reloadData()
                }

            })
        })
        Api.Closets.REF_CLOSETS.child(closetId).child("items").observe(.childRemoved, with: {snap in
            let snapId = snap.key
            if let index = self.items.index(where: {(item)-> Bool in item.id == snapId}) {
                self.items.remove(at: index)
                self.collectionView.reloadData()
            }
        })
    }
    
    
    @IBAction func openClosetList(_ sender: Any) {
        closetListShowing = !closetListShowing

        let vc = storyboard?.instantiateViewController(withIdentifier: "ClosetListViewController") as? ClosetListViewController
        vc?.delegate = self
        displayChildViewController(vc: vc!)
        view.addSubview((vc?.view)!)
        vc?.didMove(toParentViewController: self)
        vc?.view.frame = CGRect(x: 0, y: self.collectionView.frame.origin.y, width: 250, height: 600)
    
    }
    
    func displayChildViewController(vc: UIViewController) {
        addChildViewController(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }

//    @IBAction func addClothesBtn_TUI(_ sender: Any) {
//        let vc = storyboard?.instantiateViewController(withIdentifier: "AddClothesViewController") as? AddClothesViewController
//        vc?.delegate = self
//        displayChildViewController(vc: vc!)
//        view.addSubview((vc?.view)!)
//        vc?.didMove(toParentViewController: self)
//        vc?.view.frame = CGRect(x: 0, y: 0, width: 375, height: 647)
//
//    }
    
    
    func configureLikeList() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.likeList))
        likeListBtn.addGestureRecognizer(tapGesture)
        likeListBtn.isUserInteractionEnabled = true
        likeListBtn.setImage(UIImage(named: "like"), for: .normal)
        isShowingLikeItems = false
        
    }
    func configureAllList() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.allList))
        likeListBtn.addGestureRecognizer(tapGesture)
        likeListBtn.isUserInteractionEnabled = true
        likeListBtn.setImage(UIImage(named: "likeSelected"), for: .normal)
        isShowingLikeItems = true
    }
    @objc func likeList() {
        checkClosetId(closetID: closetId)
        configureAllList()
        
    }
    @objc func allList() {
        checkClosetId(closetID: closetId)
        configureLikeList()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailViewController" {
            let cell = sender as? ClosetCollectionViewCell
            let detailVC = segue.destination as! DetailViewController
            detailVC.itemId = cell?.item?.id
            detailVC.uid = self.user.uid
            
           
        }
    }
}



//MARK: - collection view extension

extension ClosetViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clothes", for: indexPath) as! ClosetCollectionViewCell
        let item = items[indexPath.row]
        cell.item = item
        
        return cell
    }
}


extension ClosetViewController: UICollectionViewDelegateFlowLayout {
    //collectionView cell 양옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    //collectionView cell 상하 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    //사진 사이즈
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.size.width / 3 - 2, height: 150)
//    }
    
}

extension ClosetViewController: ClosetListViewControllerDelegate {
    func selectedValue(Value: String) {
        self.closetId = Value
        checkClosetId(closetID: closetId)
    }

}

extension ClosetViewController: AddClothesViewControllerDelegate {
    func changeClosetIdToAll(id: String) {
        self.closetId = id
        checkClosetId(closetID: closetId)
    }
}
extension UIColor {
    
    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
