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
    
    var searchBar = UISearchBar()
    var imageView = UIImageView()
    var historyLabel = UILabel()
    var imageLabel = UILabel()
    var activityIndicator = UIActivityIndicatorView()
    var imageViewHeight: NSLayoutConstraint?
    
    var unsplashManager = UnsplashManager()
    
    // MARK: Realm
    let realm = try! Realm()
    var realmArray: Results<CacheData>?

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Constraint
        constraints()
        
        // MARK: Delegates
        searchBar.delegate = self
        unsplashManager.delegate = self
        
        // MARK: UI
        searchBarPrepare()
        labelTextPrepare(for: historyLabel, text: "Your Last Search result: ")

        if realmArray?.count == nil {
            labelTextPrepare(for: imageLabel, text: "Empty")
        }
        
        // MARK: Realm
        loadHistory()
        loadLastSearch()
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = .systemBackground
        
    }
    
    // MARK: - UI Prepare
    func searchBarPrepare() {
        navigationItem.titleView = searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Find the best image for you..."
    }
    
    func labelTextPrepare(for label: UILabel, text: String) {
        label.text = text
        label.adjustsFontSizeToFitWidth = true
    }
    
    // MARK: - Load Image Methods
    func prepareForLoadingImage(image: UIImage?) {
        guard let imageSize = image?.size, imageSize.height != 0 else { return }
        
        let maxHeigh = self.view.bounds.height * 0.7
        let aspectRatio = imageSize.width / imageSize.height
        let height = self.view.bounds.width / aspectRatio
        
        if height > maxHeigh {
            self.imageViewHeight?.constant = maxHeigh
        } else {
            self.imageViewHeight?.constant = height
        }
        
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
    }
    
    func loadLastSearch() {
        guard let realmArray = realmArray else { return }
        guard realmArray.count > 0 else { return }
        guard let data = realmArray[0].imageCache else { return }
        let image = UIImage(data: data)
        self.imageView.image = image
        self.imageLabel.text = realmArray[0].keyword
        
        prepareForLoadingImage(image: image)
    }
    
    func loadImage(url: URL) {
        let imageService = LoadImageService()
        let proxy = Proxy(service: imageService)
        proxy.loadImages(url: url) { [weak self] (data, response, error) in
            
            guard let self = self, let image = data, error == nil else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                let image = UIImage(data: image)
                self.imageView.image = image
                
                self.realmArray = nil
                self.clearRealm()
                self.sendToRealm()
                
                self.prepareForLoadingImage(image: image)
            }
        }
    }
    // MARK: - Realm Methods
    func sendToRealm() {
        realmArray = nil
        let lastImage = CacheData()
        lastImage.imageCache = cacheData
        lastImage.keyword = self.imageLabel.text
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
    
    // MARK: - Constraints
    func constraints() {
        self.view.addSubview(historyLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(imageLabel)
        self.view.addSubview(activityIndicator)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        historyLabel.translatesAutoresizingMaskIntoConstraints = false
        imageLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        historyLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        historyLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
        historyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
        imageView.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 15).isActive = true
        imageView.topAnchor.constraint(lessThanOrEqualTo: historyLabel.bottomAnchor, constant: 15).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        imageViewHeight = self.imageView.heightAnchor.constraint(equalToConstant: 0)
        imageViewHeight?.isActive = true
        imageView.contentMode = .scaleAspectFit
        
        imageLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 15).isActive = true
        imageLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        imageLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
        imageLabel.textAlignment = .center
    
        activityIndicator.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        activityIndicator.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -15).isActive = true
    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        if !CheckInternet.connection() {
            
            let alert = UIAlertController(title: "Error", message: "Lost internet connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                self.searchBar.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        unsplashManager.searchImage(keyWord: keyword)
        self.imageLabel.text = searchBar.text
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        activityIndicator.startAnimating()
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
            let alert = UIAlertController(title: "Error", message: "Nothing found. Try another keyword", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                self.searchBar.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
