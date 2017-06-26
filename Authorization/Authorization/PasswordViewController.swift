//
//  PasswordViewController.swift
//  Authorization
//
//  Created by mac on 25.06.17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

// MARK: - constants
private struct Constants {
    static let userInfoSegue = "Show User Info"
}

class PasswordViewController: UIViewController, NVActivityIndicatorViewable {
    
    // MARK: - variables
    var email: String!
    
    // MARK: - outlets
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextFieldBottom: UIView!
    
    // MARK: -actions
    @IBAction func creatingNextButton(_ sender: UITextField) {
        if let text = passwordTextField.text, !text.isEmpty {
            let nextButton = UIBarButtonItem(title: "Далее", style: UIBarButtonItemStyle.done, target: self, action: #selector(PasswordViewController.authorize(sender:)))
            navigationItem.rightBarButtonItem = nextButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    // backgroundColor changing
    @IBAction func passwordTextFieldIsActive(_ sender: UITextField) {
        passwordTextFieldBottom.backgroundColor = UIViewController.active
    }
    
    // backgroundColor changing
    @IBAction func passwordTextFieldIsInactive(_ sender: UITextField) {
        passwordTextFieldBottom.backgroundColor = UIViewController.inActive
    }
    
    // авторизация пользователя
    func authorize(sender: UIBarButtonItem) {
        let password = passwordTextField.text!
        if !User.isValidPassword(password){
            showAlert("Ошибка", "Ваш пароль должен содержать не менее 4 символов")
        }else{
            dismissKeyboard()
            startAnimating()
            // запрос на сервак
            User.authorize(email: email, password: password) { user, message in
                self.stopAnimating()
                if let message = message {
                    self.showAlert("Ошибка", message)
                } else {
                    self.performSegue(withIdentifier: Constants.userInfoSegue,
                                      sender: user!)
                }
            }
        }
    }
    
    // MARK: - navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case Constants.userInfoSegue:
            let destinationVC = segue.destination as! TokenViewController
            destinationVC.user = sender as! User
        default: break
        }
    }

}

