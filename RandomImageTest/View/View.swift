//
//  View.swift
//  RandomImageTest
//
//  Created by Vadym on 08.04.2020.
//  Copyright © 2020 Vadym Slobodianiuk. All rights reserved.
//

import UIKit

class View: UIView {
    
    var searchBar = UISearchBar()
    var imageView = UIImageView()
    var randomImage = UIImage()
    var historyLabel = UILabel()
    var imageLabel = UILabel()
    var activityIndicator = UIActivityIndicatorView()
    var imageViewHeight: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subview()
        setupUI()
        constraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func labelTextPrepare(for label: UILabel, text: String) {
        label.text = text
        label.adjustsFontSizeToFitWidth = true
    }
    
    // MARK: - Load Image Methods
    func prepareForLoadingImage(image: UIImage?) {
        guard let imageSize = image?.size, imageSize.height != 0 else { return }
        
        let maxHeigh = self.bounds.height * 0.7
        let aspectRatio = imageSize.width / imageSize.height
        let height = self.bounds.width / aspectRatio
        
        if height > maxHeigh {
            imageViewHeight?.constant = maxHeigh
        } else {
            imageViewHeight?.constant = height
        }
    }
    func alert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func subview() {
        self.addSubview(historyLabel)
        self.addSubview(imageView)
        self.addSubview(imageLabel)
        self.addSubview(activityIndicator)
    }
    
    func setupUI() {
        self.backgroundColor = .systemBackground
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        historyLabel.translatesAutoresizingMaskIntoConstraints = false
        imageLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.sizeToFit()
        imageView.contentMode = .scaleAspectFit
        imageLabel.textAlignment = .center
    }
    
    // MARK: - Constraints
    func constraints() {

        historyLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        historyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        historyLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        
        imageView.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 15).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        imageViewHeight = self.imageView.heightAnchor.constraint(equalToConstant: 0)
        imageViewHeight?.isActive = true
        
        imageLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 15).isActive = true
        imageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        imageLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
    
        activityIndicator.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        activityIndicator.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
    }
}
