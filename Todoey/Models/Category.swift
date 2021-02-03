//
//  Category.swift
//  Todoey
//
//  Created by Rodrigo Maidana on 29/01/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name = ""
    let items = List<Item>()
}
