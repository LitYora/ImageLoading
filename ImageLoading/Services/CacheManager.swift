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
    
    private let sizeLimit = 100000000
    private let fileManager = FileManager.default
    
    
    //MARK:- Cache Image
    ///completion is executed on the background thread
    func cacheImage(_ image: UIImage?, with id: Int, completion: ((Bool) -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async { [self] in
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
    }
    
    //MARK:- Get Image
    func getImage(with id: Int, completion: @escaping (UIImage?) -> Void) {
        let imageUrl = getCachesDirectory().appendingPathComponent("\(id)")
        DispatchQueue.global(qos: .userInteractive).async {
            let image = self.getImage(from: imageUrl.path)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func getImage(from path: String) -> UIImage? {
        if let data = fileManager.contents(atPath: path),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    func getCachedImages(completion: @escaping ([UIImage], [String]) -> Void) {
        DispatchQueue.global().async { [self] in
            var images = [UIImage]()
            var imagesId = [String]()
            let imagePaths = getCachedImagesPaths()
            for path in imagePaths {
                if let image = getImage(from: path) {
                    images.append(image)
                    imagesId.append(path.components(separatedBy: "/").last ?? "0")
                }
            }
            DispatchQueue.main.async {
                completion(images, imagesId)
            }
        }
        
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
    
    func comparingCacheAndURL(info: ImageInfo, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async { [self] in
            var image = UIImage()
            for fileURL in getCachedImagesPaths() {
                if ("\(info.id)") == fileURL.split(separator: "/").last {
                    image = getImage(from: ("\(fileURL)"))!
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
      //      completion(nil)
        }
    }
    
    func getURLById(){
        
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
