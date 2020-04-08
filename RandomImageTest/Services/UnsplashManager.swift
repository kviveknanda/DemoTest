//
//  UnsplashManager.swift
//  RandomImageTest
//
//  Created by Vadym on 07.04.2020.
//  Copyright © 2020 Vadym Slobodianiuk. All rights reserved.
//

import Foundation

protocol UnsplashManagerDelegate {
    func didGetImage(_ imageManager: UnsplashManager, image: ImageModel)
    func nothingFound()
    func didFailWithError(error: Error)
}

struct UnsplashManager {
    
    var delegate: UnsplashManagerDelegate?
    
    let apiKey = "1HYvvwRFi6scettWZtSybqiyJhTMg33z8W3fyR_DxTc"
    let unsplashURL = "https://api.unsplash.com/search/photos?"
    let param = "&query="
    
    func searchImage(keyWord:String) {
        let urlString = "\(unsplashURL)client_id=\(apiKey)\(param)\(keyWord)"
        performRequest(urlString)
    }
    
    func performRequest(_ urlString: String) {
        //MARK: Steps for Networking
        // MARK: Create a URL
        if let url = URL(string: urlString) {
            // MARK:  Create a URLSession
            let session = URLSession(configuration: .default)
            
            // MARK:  Give the session a task
            let task = session.dataTask(with: url) { (data, responce, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    //let stringData = String(data: safeData, encoding: .utf8)
                    //print(stringData!)
                    
                    if let image = self.parseJSON(safeData) {
                        self.delegate?.didGetImage(self, image: image)
                    }
                }
            }
            // MARK: Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> ImageModel? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(ImageData.self, from: weatherData)
            
            if decodeData.results.count == 0 {
                self.delegate?.nothingFound()
                return nil
            }
            
            let randomInt = Int.random(in: 0..<decodeData.results.count)
            let stringUrl = decodeData.results[randomInt].urls.regular
            let image = ImageModel(imageUrl: stringUrl)
            
            return image
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
