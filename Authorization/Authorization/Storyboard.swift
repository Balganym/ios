//
//  Storyboard.swift
//  Authorization
//
//  Created by mac on 27.06.17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

private struct Constants {
    static let storyboard = "Authorization"
    
    static let authorizationNC = "mainView"
    
    static let userInfoNC = "User Info"
}

struct Storyboard {
    static let storyboard = UIStoryboard(name: Constants.storyboard, bundle: nil)
    
    static var authorizationNC: UINavigationController {
        return storyboard.instantiateViewController(withIdentifier: Constants.authorizationNC) as! UINavigationController
    }
    
    static var userInfoNC: UINavigationController {
        return storyboard.instantiateViewController(withIdentifier: Constants.userInfoNC) as! UINavigationController
    }
}
