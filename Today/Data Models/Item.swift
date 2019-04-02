//
//  Item.swift
//  Today
//
//  Created by 謝冠緯 on 2019/3/29.
//  Copyright © 2019年 謝冠緯. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var checked : Bool = false
    
    @objc dynamic var createdDate : Date?
    
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
