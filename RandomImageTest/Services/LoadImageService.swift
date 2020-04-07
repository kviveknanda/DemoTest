//
//  LoadImageService.swift
//  RandomImageTest
//
//  Created by Vadym on 07.04.2020.
//  Copyright © 2020 Vadym Slobodianiuk. All rights reserved.
//

import Foundation

var cacheData: Data? = nil

protocol LoadServiseProtocol {
    func loadImages(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

class LoadImageService: LoadServiseProtocol {
    func loadImages(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let config = URLSessionConfiguration.default
        // MARK: Не храним кеш стандартными методами
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        // MARK: Создаем сессию со своими параметрами, без стандартного кеширования
        let session = URLSession.init(configuration: config)
        session.dataTask(with: url, completionHandler: completion).resume()
    }
}

class Proxy: LoadServiseProtocol {
    private var service: LoadServiseProtocol
    
    init(service: LoadServiseProtocol) {
        self.service = service
    }
    
    func loadImages(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        service.loadImages(url: url) { (data, response, error) in
            cacheData = data
            completion(data, response, error)
        }
    }
}
