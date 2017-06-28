//
//  UserInfoViewController.swift
//  Authorization
//
//  Created by mac on 28.06.17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController {
    
    // MARK: - variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var user = Storage.user! {
        didSet {
            updateUI()
        }
    }
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - internal functions
    private func updateUI() {
        nameLabel?.text = user.name
        emailLabel?.text = "email: " + user.email
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        Storage.user = nil
        appDelegate.openView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        spinner.startAnimating()
        // загрузка аватарки
        GettingImage.fetchImage(with: user.avatar) { image in
            self.imageView.image = image
            self.spinner.stopAnimating()
        }
        GettingImage.setRounded(imageView)
    }

    
}
