//
//  CacheManager.swift
//  ImageLoading
//
//  Created by Matvei  on 06.01.2021.
//

import UIKit

class CacheManager {
    private init() {}
    
    static let shared = CacheManager()
    
    //private let imagesLimit = 100
    private let sizeLimit = 100000000
    private let fileManager = FileManager.default
    
    
    //MARK:- Cache Image
    func cacheImage(_ image: UIImage?, with id: Int, completion: ((Bool) -> Void)? = nil) {
        guard let image = image,
              let data = image.pngData()
        else {
            completion?(false)
            return
        }
        
        let imageUrl = getCachesDirectory().appendingPathComponent("\(id)")
        
        guard !fileManager.fileExists(atPath: imageUrl.path) else {
            completion?(true)
            return
        }
        
        var savedPaths = getCachedImagesPaths()
        //while imagesLimit <= savedPaths.count {
        while sizeLimit <= directorySize(url: getCachesDirectory()) {
           _ = deleteImage(path: savedPaths.first!)
            savedPaths.remove(at: savedPaths.startIndex)
        }
        
        do{
            try data.write(to: imageUrl)
            print("Image was saved to: \(imageUrl)")
            completion?(true)
        }
        catch {
            print(error)
            completion?(false)
        }
        
    }
    
    //MARK:- Get Image
    func getImage(with id: Int, completion: (UIImage?) -> Void) {
        let imageUrl = getCachesDirectory().appendingPathComponent("\(id)")
        let image = getImage(from: imageUrl.path)
        completion(image)
    }
    
    func getImage(from path: String) -> UIImage? {
        if let data = fileManager.contents(atPath: path),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    func getCachedImages(completion: ([UIImage]) -> Void) {
        var images = [UIImage]()
        let imagePaths = getCachedImagesPaths()
        for path in imagePaths {
            if let image = getImage(from: path) {
                images.append(image)
            }
        }
        completion(images)
    }
    
    //MARK:- Delete Image
    func deleteImage(id: Int) -> Bool {
        let imageUrl = getCachesDirectory().appendingPathComponent("\(id)")
        return deleteImage(path: imageUrl.path)
    }
    
    func deleteImage(path: String) -> Bool {
        do {
            try fileManager.removeItem(atPath: path)
            return true
        }
        catch {
            return false
        }
    }
    
    //MARK:- Private
    private func getCachedImagesPaths() -> [String] {
        do {
            let paths = try fileManager.contentsOfDirectory(atPath: getCachesDirectory().path)
            return paths.map { getCachesDirectory().appendingPathComponent($0).path }
        }
        catch {
            return []
        }
    }
    
    private func getCachesDirectory() -> URL {
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("CachedImages")
        
        if !fileManager.fileExists(atPath: url.path) {
            try! fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
    
    //MARK:- Size Counter
    func directorySize(url: URL) -> Int64 {
        let contents: [URL]
        do {
            contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey])
        } catch {
            return 0
        }

        var size: Int64 = 0

        for url in contents {
           // let isDirectoryResourceValue: URLResourceValues

                let fileSizeResourceValue: URLResourceValues
                do {
                    fileSizeResourceValue = try url.resourceValues(forKeys: [.fileSizeKey])
                } catch {
                    continue
                }

                size += Int64(fileSizeResourceValue.fileSize ?? 0)
        }
        return size
    }
}
