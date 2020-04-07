//
//  imageData.swift
//  RandomImageTest
//
//  Created by Vadym on 07.04.2020.
//  Copyright © 2020 Vadym Slobodianiuk. All rights reserved.
//

import Foundation

struct ImageData: Codable {
    let results: [UnsplashResults]
}

struct UnsplashResults: Codable {
    let urls: Urls
}

struct Urls: Codable {
    let raw: String
}
