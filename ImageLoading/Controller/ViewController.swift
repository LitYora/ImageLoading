//
//  ViewController.swift
//  ImageLoading
//
//  Created by Matvei  on 07.12.2020.
//

import UIKit

class ViewController: UIViewController {

@IBOutlet weak var collectionView: UICollectionView!

    private var images: [UIImage?] = []
    private var imagesInfo = [ImageInfo]()
    
    private let spacing: CGFloat = 5
    private let numberOfItemsPerRow: CGFloat = 3
    
    //MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        loadImages()
    }
    
    private func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func loadImages() {
        NetworkService.shared.fetchImages(amount: 60) { (result) in
            switch result {
            case let .failure(error):
                print(error)
                
            case let .success(imagesInfo):
                self.imagesInfo = imagesInfo
                self.images = Array(repeating: nil, count: imagesInfo.count)
                self.collectionView.reloadData()
            }
        }
    }
    
    private func loadImage(for cell: ImageCell, at index: Int) {
        let info = imagesInfo[index]
        if let image = images[index] {
            cell.configure(with: image)
            return
        }
        NetworkService.shared.loadImage(from: info.webformatURL) { (image) in
            self.images[index] = image
            cell.configure(with: self.images[index])
        }
    }

}

//MARK:- Data Source & Delegate
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
            fatalError("Invalid Cell Kind")
        }
//        cell.layer.borderColor = UIColor.black.cgColor
//        cell.layer.borderWidth = 2

        loadImage(for: cell, at: indexPath.row)
        
        return cell
    }
}


//MARK:- Flow Layout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.bounds.width
        let summarySpacing = spacing * (numberOfItemsPerRow - 1)
        let insets = 2 * spacing  // leftInset + rightInset (of section)
        
        let rawWidth = width - summarySpacing - insets
        
        let cellWidth = rawWidth / numberOfItemsPerRow
        
        return CGSize(width: cellWidth, height: cellWidth)
        
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: spacing,
                     left: spacing,
                     bottom: spacing,
                     right: spacing
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}



