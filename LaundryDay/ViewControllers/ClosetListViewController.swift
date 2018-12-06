//
//  TestViewController.swift
//  LaundryDay
//
//  Created by CAUADC on 2018. 6. 1..
//  Copyright © 2018년 MBP03. All rights reserved.
//

import UIKit
import ProgressHUD

class ClosetListViewController: UIViewController {
    
   
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var allItems: UILabel!
    
    //var closetName: String?
    var myClosets = [Closet]()


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = headerView
        headerView.dropShadow()
        
        fetchMyClosets()
        changeToAll()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func fetchMyClosets() {
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        Api.MyClosets.REF_MYCLOSETS.child(currentUser.uid).observe(.childAdded, with: {snapshot in
            Api.Closets.observeCloset(withId: snapshot.key, completion: { closet in
                self.myClosets.append(closet)
                self.tableView.reloadData()
            })
        })
        
        Api.MyClosets.REF_MYCLOSETS.child(currentUser.uid).observe(.childRemoved, with: {snap in
            let snapId = snap.key
            if let index = self.myClosets.index(where: {(item)-> Bool in item.id == snapId}) {
                self.myClosets.remove(at: index)
                self.tableView.reloadData()
            }
        })
        
    }
    
    @IBAction func addListButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: "옷장 추가하기", message: "옷장 이름을 정해주세요", preferredStyle: .alert)
        
        actionSheet.addTextField(configurationHandler: {textField in
            textField.text = ""
        })
        
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .default, handler: {(_) in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "다음", style: .default, handler: {(_) in
            //ProgressHUD.show("Waiting")
            guard let closetName = actionSheet.textFields?[0].text else {
                return
            }
            if let vc = UIStoryboard(name: "Closet", bundle: nil).instantiateViewController(withIdentifier: "AddClothesToClosetViewController") as? AddClothesToClosetViewController {
                self.present(vc, animated: true, completion: nil)
                vc.closetName = closetName
            }


        }))
        self.present(actionSheet,animated: true,completion: nil)
    }

    
    @IBAction func cancelButton_TUI(_ sender: Any) {
        
        ClosetListViewController.removeViewController(childVC: self)
        
    }
    
    func changeToAll() {
        let tapGestureForAllItems = UITapGestureRecognizer(target: self, action: #selector(self.setListToAll))
        allItems.addGestureRecognizer(tapGestureForAllItems)
        allItems.isUserInteractionEnabled = true
    }
    
    @objc func setListToAll() {
        if (delegate != nil) {
            delegate?.selectedValue(Value: "All")
        }
        
        ClosetListViewController.removeViewController(childVC: self)
    }
    
   
    var delegate: ClosetListViewControllerDelegate?
    
    public class func removeViewController(childVC: UIViewController) {
        childVC.willMove(toParentViewController: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParentViewController()
    }

   
    
    
}

protocol ClosetListViewControllerDelegate {
    func selectedValue(Value: String)
}




extension ClosetListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myClosets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClosetListTableViewCell", for: indexPath) as! ClosetListTableViewCell
        let closet = myClosets[indexPath.row]
        cell.closet = closet
        
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = myClosets[indexPath.row]
        let selectedCellClosetId = selectedCell.id

        if (delegate != nil) {
            delegate?.selectedValue(Value: selectedCellClosetId!)
        }
        
        ClosetListViewController.removeViewController(childVC: self)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let deleteCell = myClosets[indexPath.row]
            guard let currentUser = Api.User.CURRENT_USER else{
                return
            }
            //내 옷장에서 지움
            Api.MyClosets.REF_MYCLOSETS.child(currentUser.uid).child(deleteCell.id!).removeValue()
            //옷장 안에서 지움
            Api.Closets.REF_CLOSETS.child(deleteCell.id!).removeValue()
            setListToAll()
            
        }
    }
    
    
    

}

extension ClosetListViewController: UITableViewDelegate {
    
}

