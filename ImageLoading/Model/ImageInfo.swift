//
//  ImageInfo.swift
//  ImageLoading
//
//  Created by Matvei  on 07.12.2020.
//

import Foundation

struct ImageInfo: Decodable {
    var id: Int
    var previewURL: URL?
    var webformatURL: URL?
    var likes: Int
    var comments: Int
    var user: String
    var views: Int
}
