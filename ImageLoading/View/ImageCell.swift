//
//  ImageCell.swift
//  ImageLoading
//
//  Created by Matvei  on 08.12.2020.
//

import UIKit

class ImageCell: UICollectionViewCell {
    static let identifier = "ImageCell"
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        //activityIndicator.startAnimating()
    }
    
    func configure(with image: UIImage?) {
        activityIndicator.stopAnimating()
        imageView.image = image
    }
    
}

