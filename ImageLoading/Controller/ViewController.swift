//
//  ViewController.swift
//  ImageLoading
//
//  Created by Matvei  on 07.12.2020.
//

import UIKit

class ViewController: UIViewController, UISearchResultsUpdating {

@IBOutlet weak var collectionView: UICollectionView!

    private var images: [UIImage?] = []
    private var imagesInfo = [ImageInfo]()
    private var imagesId = [String]()
    
    private let spacing: CGFloat = 5
    private let numberOfItemsPerRow: CGFloat = 3
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let noResultLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))

    
    //MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        getCachedImages()
        //loadImages(request: "")
    }
    
    private func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Photos"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        noResultLabel.isHidden = true
        noResultLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        noResultLabel.textColor = .gray
        noResultLabel.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        noResultLabel.textAlignment = .center
        noResultLabel.text = "No Matches"
        self.view.addSubview(noResultLabel)
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        noResultLabel.isHidden = true
        let text = searchController.searchBar.text
        guard let request = text?.replacingOccurrences(of: " ", with: "+"), (request.count >= 3 || request.count == 0)  else { return }
        loadImages(request: request)
        if request == "" {
            noResultLabel.isHidden = true
        }
        
    }

    private func loadImages(request: String) {
        images.removeAll()
        self.updateUI()
        NetworkService.shared.fetchImages(amount: 60, request: request) { (result) in
            switch result {
            case let .failure(error):
                print(error)
                
            case let .success(imagesInfo):
                self.imagesInfo = imagesInfo
                self.images = Array(repeating: nil, count: imagesInfo.count)
                self.updateUI()
                if self.images.isEmpty {
                    self.noResultLabel.isHidden = false
                } else { self.noResultLabel.isHidden = true}
            }
        }
    }
    
    private func updateUI() {
        self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
    }
    
    private func getCachedImages() {
        noResultLabel.isHidden = true
        CacheManager.shared.getCachedImages { (images, imagesId) in
            self.images = images
            self.imagesId = imagesId
            self.updateUI()
        }
    }
    
    private func loadImage(for cell: ImageCell, at index: Int) {
        cell.activityIndicator.startAnimating()
        if let image = images[index] {
            cell.configure(with: image)
            return
        }
        let info = imagesInfo[index]
//        var cachedImage = UIImage()
//        CacheManager.shared.comparingCacheAndURL(index: index, info: info) { (image) in
//            cachedImage = image
//            cell.configure(with: cachedImage)
//            return
//        }
//        if cachedImage.imageAsset != nil {
//            cell.configure(with: cachedImage)
//            return
//        }
        NetworkService.shared.loadImage(from: info.webformatURL, imageInfo: imagesInfo[index]) { (image) in
            if index < self.images.count {
                self.images[index] = image
                CacheManager.shared.cacheImage(image, with: info.id)
                cell.configure(with: self.images[index])
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSecondVC" {
            guard let secondVC = segue.destination as? DetailViewController,
                  let imageInfo = sender as? ImageInfo
            else {
                fatalError("Inccorect data passed when showing detailVC")
            }
            secondVC.imageInfo = imageInfo
        }
    }

}

//MARK:- Data Source & Delegate
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
            fatalError("Invalid Cell Kind")
        }
        cell.activityIndicator.startAnimating()
        loadImage(for: cell, at: indexPath.row)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        performSegue(withIdentifier: "ShowSecondVC", sender: imagesInfo[indexPath.row])
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
                     right: spacing //* 8 + 3
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        cell.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.01 * Double(indexPath.row), animations: {
              cell.alpha = 1
        })
    }
}

//MARK:- SearchBar
//extension ViewController : UISearchBarDelegate {
//    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
//        return true
//    }
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        guard let request = searchBar.text, request.count >= 3 else {
//            return
//        }
//        loadImages(request: request)
//    }
//}

