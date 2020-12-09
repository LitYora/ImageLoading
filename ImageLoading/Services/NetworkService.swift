//
//  NetworkService.swift
//  ImageLoading
//
//  Created by Matvei  on 07.12.2020.
//

import UIKit

class NetworkService {
    private init() {}

    static let shared = NetworkService()
    
    private let apiKey = "19427384-aba8c25dcff1b4cbfb1e4d048"
    
    private var baseUrlComponent: URLComponents {
        var _urlComps = URLComponents(string: "https://pixabay.com")!
        _urlComps.path = "/api"
        _urlComps.queryItems = [
            URLQueryItem(name: "key", value: apiKey)
        ]
        return _urlComps
    }



    //MARK:-LoadImage
    func loadImage(from url: URL?, completion: @escaping(UIImage?) -> Void) {
        guard let url = url else {
            completion(nil)
            return
        }
    
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            DispatchQueue.main.async {
                if let data = data {
                    completion(UIImage(data: data))
                } else {
                    completion(nil)
                }
            }
        
        }.resume()
    
    }
    
    //MARK:- Fetch Images
    func fetchImages(amount: Int, request: String?, completion: @escaping (Result<[ImageInfo], SessionError>) -> Void) {
        var urlComps = baseUrlComponent
        if request == "" {
        urlComps.queryItems? += [
            URLQueryItem(name: "per_page", value: "\(amount)"),
            URLQueryItem(name: "editors_choice", value: "\(true)")
        ] } else {
            urlComps.queryItems? += [
                URLQueryItem(name: "per_page", value: "\(amount)"),
                URLQueryItem(name: "q", value: request)
            ]
        }
        guard let url = urlComps.url else {
            completion(.failure(.invalidUrl))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.other(error)))
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            guard let data = data, response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(.serverError(response.statusCode)))
                }
                return
            }
            
            do {
                let serverResponse = try JSONDecoder().decode(ServerResponse<ImageInfo>.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(serverResponse.hits))
                }
            }
            catch let decodingError {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(decodingError)))
                }
            }
            
        }.resume()
    }
    
}
