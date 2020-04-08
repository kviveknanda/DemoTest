//
//  ViewController.swift
//  RandomImageTest
//
//  Created by Vadym on 07.04.2020.
//  Copyright © 2020 Vadym Slobodianiuk. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    // MARK: Properties
    let customView = View()
    var unsplashManager = UnsplashManager()
    let realm = try! Realm()
    var realmArray: Results<CacheData>?

    // MARK: - loadView
    override func loadView() {
        self.view = customView
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Delegates
        customView.searchBar.delegate = self
        unsplashManager.delegate = self
        
        // MARK: Add Search Bar
        self.navigationItem.titleView = customView.searchBar
        
        // MARK: UI Text
        textUI()
        
        // MARK: Realm
        loadHistory()
        loadLastSearch()
    }
    
    // MARK: - Methods
    func textUI() {
        customView.searchBar.placeholder = "Find the best image for you..."
        customView.labelTextPrepare(for: customView.historyLabel, text: "Your Last Search result:")
        
        if realmArray?.count == nil {
            customView.labelTextPrepare(for: customView.imageLabel, text: "Empty")
        }
    }
    
    func loadLastSearch() {
        guard let realmArray = realmArray else { return }
        guard realmArray.count > 0 else { return }
        guard let data = realmArray[0].imageCache else { return }
        
        DispatchQueue.main.async {
            guard let imageData = UIImage(data: data) else { return }
            self.customView.randomImage = imageData
            self.customView.imageView.image = self.customView.randomImage
            self.customView.imageLabel.text = realmArray[0].keyword
            self.customView.prepareForLoadingImage(image: self.customView.randomImage)
        }
    }
    
    func loadImage(url: URL) {
        let imageService = LoadImageService()
        let proxy = Proxy(service: imageService)
        proxy.loadImages(url: url) { [weak self] (data, response, error) in
            
            guard let self = self, let image = data, error == nil else { return }
            DispatchQueue.main.async {
                self.customView.activityIndicator.stopAnimating()
                if let imageData = UIImage(data: image) {
                    self.customView.randomImage = imageData
                    self.customView.imageView.image = self.customView.randomImage
                    
                    self.realmArray = nil
                    self.clearRealm()
                    self.sendToRealm()
                    
                    self.customView.prepareForLoadingImage(image: self.customView.randomImage)
                } else {
                    self.customView.alert(title: "Error", message: "Couldn't show image", viewController: self)
                }
            }
        }
    }
    
    // MARK: - Realm Methods
    func sendToRealm() {
        realmArray = nil
        let lastImage = CacheData()
        lastImage.imageCache = cacheData
        lastImage.keyword = customView.imageLabel.text
        self.save(data: lastImage)
    }
    
    func save(data: CacheData) {
        do {
            try realm.write {
                realm.add(data)
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func clearRealm() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Error removing items, \(error)")
        }
    }
    
    func loadHistory() {
        realmArray = realm.objects(CacheData.self)
    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        if !CheckInternet.connection() {
            
            customView.alert(title: "Error", message: "Lost internet connection", viewController: self)
            return
        }
        unsplashManager.searchImage(keyWord: keyword)
        customView.imageLabel.text = searchBar.text
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        customView.activityIndicator.startAnimating()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}

// MARK: - UnsplashManagerDelegate
extension ViewController: UnsplashManagerDelegate {
    func didGetImage(_ imageManager: UnsplashManager, image: ImageModel) {
        guard let url = URL(string: image.imageUrl) else { return }
        loadImage(url: url)
    }
    
    func nothingFound() {
        DispatchQueue.main.async {
            self.customView.alert(title: "Error", message: "Nothing found. Try another keyword", viewController: self)
            self.customView.activityIndicator.stopAnimating()
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            self.customView.alert(title: "Error", message: "Couldn't get image from Unsplash", viewController: self)
            self.customView.activityIndicator.stopAnimating()
        }
        print(error)
    }
}
