//
//  imageDownloader.swift
//  imageDownloader1
//
//  Created by mac on 21.06.17.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
struct ImageDownloader {
    
    static func fetchImage(with url: String,
                           completion: @escaping (UIImage) -> Void) {
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value {
                completion(image)
            }
        }
    }
}
