//
//  EmailViewController.swift
//  Authorization
//
//  Created by mac on 25.06.17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

// MARK: - constants
private struct Constants {
    static let passwordSegue = "Show Password"
}

class EmailViewController: UIViewController {
    
    // MARK: - outlets
    @IBOutlet weak var textFieldBottom: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: - actions
    @IBAction func textChanging(_ sender: UITextField) {
        if let text = emailTextField.text, !text.isEmpty {
            let rightBarButton = UIBarButtonItem(title: "Далее", style: UIBarButtonItemStyle.done, target: self, action: #selector(EmailViewController.showPassword(sender:)))
            navigationItem.rightBarButtonItem = rightBarButton
        }else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    //меняем цвет под'view'шки (когда он активен)
    @IBAction func textFieldIsActive(_ sender: UITextField) {
        textFieldBottom.backgroundColor = UIViewController.active
    }
    //меняем цвет под'view'шки (не активен)
    @IBAction func textFieldIsInactive(_ sender: UITextField) {
        textFieldBottom.backgroundColor = UIViewController.inActive
    }
    
    // переход на страницу с вводом пороля
    func showPassword(sender: UIBarButtonItem){
        let email = emailTextField.text!
        if User.isValidEmail(email) {
            performSegue(withIdentifier: Constants.passwordSegue, sender: email)
        } else {
            showAlert("Ошибка", "Неправильный email. Введите снова.")
        }
    }
    
    // MARK: - navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Назад"
        navigationItem.backBarButtonItem = backItem
        switch segue.identifier! {
        case Constants.passwordSegue:
            let destinationVC = segue.destination as! PasswordViewController
            destinationVC.email = sender as! String
        default: break
        }
    }
}
