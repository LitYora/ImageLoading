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
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with image: UIImage?) {
        imageView.image = image
    }
    
}

