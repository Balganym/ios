//
//  TokenViewController.swift
//  Authorization
//
//  Created by mac on 25.06.17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class TokenViewController: UIViewController {
    
    // MARK: - variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var user: User! {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - outlets
    @IBOutlet weak var tokenLabel: UILabel!
    
     // MARK: - actions
    @IBAction func logOut(_ sender: UIButton) {
        User.deleteUser()
        appDelegate.openView("emailView")
    }
    
    // MARK: - internal functions
    private func updateUI() {
        tokenLabel?.text = user.token
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let newUser = appDelegate.isThereUser() {
            user = newUser
        }
        updateUI()
    }
    
}
