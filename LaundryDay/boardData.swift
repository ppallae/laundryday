//
//  boardData.swift
//  LaundryDay
//
//  Created by 정아 on 04/12/2018.
//  Copyright © 2018 MBP03. All rights reserved.
//

import Foundation
import UIKit

let g_NumPerOneLoad = 5 //한 load에 불러올 게시글의 수

class Post {
    var title:String //게시글 제목
    var text:String //게시글 내용
    var date:Int //게시 시간
    var imageView = UIImageView() //게시 이미지
    
    init(_ title:String, _ text:String, _ date:Int) {
        self.title = title
        self.text = text
        self.date = date
    }
}
