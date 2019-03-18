//
//  ItemClass.swift
//  Today
//
//  Created by 謝冠緯 on 2019/3/18.
//  Copyright © 2019年 謝冠緯. All rights reserved.
//

import Foundation

class Item {
    var title: String
    var checked: Bool

    init(toDoListTitle titleString: String = "", isChecked checked: Bool = false) {
        self.title = titleString
        self.checked = checked
    }
}
