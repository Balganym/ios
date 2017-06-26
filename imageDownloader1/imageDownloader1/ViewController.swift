//
//  ViewController.swift
//  imageDownloader1
//
//  Created by mac on 21.06.17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = "https://www.w3schools.com/css/img_forest.jpg"
        spinner.startAnimating()
        ImageDownloader.fetchImage(with: url) { image in
            self.spinner.stopAnimating()
            self.imageView.image = image
        }
    }

}

