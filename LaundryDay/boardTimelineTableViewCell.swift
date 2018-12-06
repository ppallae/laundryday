//
//  boardTimelineTableViewCell.swift
//  LaundryDay
//
//  Created by 정아 on 04/12/2018.
//  Copyright © 2018 MBP03. All rights reserved.
//

import UIKit

class boardTimelineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var TextLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    //@IBOutlet weak var ImageView: UIImageView!
    
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        // Initialization codey
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
