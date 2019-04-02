//
//  Category.swift
//  Today
//
//  Created by 謝冠緯 on 2019/3/29.
//  Copyright © 2019年 謝冠緯. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    
    let items = List<Item>()

}
