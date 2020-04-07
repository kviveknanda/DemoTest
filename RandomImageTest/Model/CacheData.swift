//
//  CacheData.swift
//  RandomImageTest
//
//  Created by Vadym on 07.04.2020.
//  Copyright © 2020 Vadym Slobodianiuk. All rights reserved.
//

import Foundation
import RealmSwift

class CacheData: Object {
    @objc dynamic var imageCache: Data?
    @objc dynamic var keyword: String?
}
