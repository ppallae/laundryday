//
//  MyPostsTableViewCell.swift
//  LaundryDay
//
//  Created by mjcho on 2018. 12. 9..
//  Copyright © 2018년 MBP03. All rights reserved.
//

import UIKit

class MyPostsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    

    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        titleLabel.text = post?.title
        postTextLabel.text = post?.text
        if let dateStr = post?.date {
            dateLabel.text = String(dateStr)
        } else {
            dateLabel.text = "0000/00/00"
        }
    }
}
