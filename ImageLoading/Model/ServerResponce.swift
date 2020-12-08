//
//  ServerResponce.swift
//  ImageLoading
//
//  Created by Matvei  on 08.12.2020.
//

import Foundation

struct ServerResponse<Object: Decodable>: Decodable  {
    var hits: [Object]
}
