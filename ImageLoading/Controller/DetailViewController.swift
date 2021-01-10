//
//  DetailViewController.swift
//  ImageLoading
//
//  Created by Matvei  on 12.12.2020.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    
    @IBOutlet weak var likeLabelText: UILabel!
    @IBOutlet weak var commentLabelText: UILabel!
    @IBOutlet weak var userLabelText: UILabel!
    @IBOutlet weak var viewsLabelText: UILabel!
    
    var imageInfo = ImageInfo(id: 0, likes: -1, comments: -1, user: "", views: -1)
//        var ImageUrl: URL?
//        var like = 0
//        var comment = 0
//    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        configure()

    }
    
    private func configure() {
        likeLabelText.text = "\(imageInfo.likes)"
        commentLabelText.text = "\(imageInfo.comments)"
        userLabelText.text = imageInfo.user
        viewsLabelText.text = "\(imageInfo.views)"
    }
    
    private func loadImage() {

        NetworkService.shared.loadImage(from: imageInfo.webformatURL, imageInfo: imageInfo) { (image) in
            self.detailImageView.image = image
            
        }
    }

}
