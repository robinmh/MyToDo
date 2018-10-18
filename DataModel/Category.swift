//
//  Category.swift
//  MyToDo
//
//  Created by Robin on 17/10/18.
//  Copyright © 2018 RamonSoftware. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name : String = ""
    
   var items = List<Item>()
    
}
