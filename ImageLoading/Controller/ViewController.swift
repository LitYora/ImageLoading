//
//  ViewController.swift
//  ImageLoading
//
//  Created by Matvei  on 07.12.2020.
//

import UIKit

class ViewController: UIViewController, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        guard let request = text?.replacingOccurrences(of: " ", with: "+") else { return  }
        loadImages(request: request)
        
    }

@IBOutlet weak var collectionView: UICollectionView!

    private var images: [UIImage?] = []
    private var imagesInfo = [ImageInfo]()
    
    private let spacing: CGFloat = 5
    private let numberOfItemsPerRow: CGFloat = 3
    
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        loadImages(request: "")
    }
    
    private func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Photos"
        navigationItem.searchController = searchController
        definesPresentationContext = true
//        searchController.searchBar.backgroundColor = .systemPink
//        navigationController?.navigationBar.backgroundColor = .systemPink

    }
    
    private func loadImages(request: String) {
        NetworkService.shared.fetchImages(amount: 60, request: request) { (result) in
            switch result {
            case let .failure(error):
                print(error)
                
            case let .success(imagesInfo):
                self.imagesInfo = imagesInfo
                self.images = Array(repeating: nil, count: imagesInfo.count)
                self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
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
            if index < self.images.count {
                self.images[index] = image
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
        return imagesInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
            fatalError("Invalid Cell Kind")
        }

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
                     right: spacing //* 8 + 3
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSecondVC", sender: imagesInfo[indexPath.row])
    }
}

//MARK:- SearchBar
extension ViewController : UISearchBarDelegate {
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let request = searchBar.text, request.count >= 3 else {
            return
        }
        loadImages(request: request)
    }
}

//MARK:- PerformSegue

