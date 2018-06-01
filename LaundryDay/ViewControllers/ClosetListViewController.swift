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
    
    var closetName: String?
    var myClosets = [Closet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = headerView
        
        fetchMyClosets()

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
    }
    
    @IBAction func addListButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: "옷장 추가하기", message: "옷장 이름을 정해주세요", preferredStyle: .alert)
        
        actionSheet.addTextField(configurationHandler: {textField in
            textField.text = ""
        })
        
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .default, handler: {(_) in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "추가", style: .default, handler: {(_) in
            ProgressHUD.show("Waiting")
            self.closetName = actionSheet.textFields?[0].text
            if let closetNameText = self.closetName {
                HelperService.sendClosetDataToDatabase(closetName: closetNameText, onSuccess: {
                    self.tableView.reloadData()
                    print("success")
                    })
            } else {
                //TODO: 텍스트 비워졌을때 오류 나야하는데ㅜㅜ
                ProgressHUD.showError("텍스트를 입력해주세요")
            }
            
        }))
        self.present(actionSheet,animated: true,completion: nil)
    }
    
    
    
 
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

}

extension ClosetListViewController: UITableViewDelegate {
    
}
