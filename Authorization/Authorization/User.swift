//
//  User.swift
//  Authorization
//
//  Created by mac on 25.06.17.
//  Copyright © 2017 mac. All rights reserved.
//

import Alamofire
import ObjectMapper

// функуции будут видны для всех UIViewController'ов
extension UIViewController {
    
    //функция alert
    func showAlert(_ alertTitle: String, _ alertMessage: String) {
        let alertView = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "ОK", style: .default, handler: nil))
        present(alertView, animated:true, completion:nil)
    }
    
    static let active = UIColor(red: 0/255, green: 204/255, blue: 255/255, alpha: 1)
    static let inActive = UIColor(red: 112/255, green: 125/255, blue: 164/255, alpha: 1)
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

struct User: Mappable {
    
    var id = 0
    var email = ""
    var name = ""
    var avatar = ""
    
    init?(map: Map) { }
    mutating func mapping(map: Map) {
        id <- map["user.id"]
        email <- map["user.email"]
        name <- map["user.full_name"]
        avatar <- map["user.avatar"]
    }
    
    // авторизация пользователя
    static func authorize(email: String,
                          password: String,
                          completion: @escaping (User?, String?) -> Void) {
        let parameters = [
            "username": email,
            "password": password
        ]
        let url = "https://apivotem.solf.io/api/authe/login/"
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = value as! [String: Any]
                print(json)
                let code = json["code"] as! Int
                switch code {
                case 0:
                    completion(User(JSON: json)!, nil)
                case 6:
                    completion(nil, "Пользователь с таким email не найден")
                default:
                    completion(nil, "Пришел код ошибки, который мы не обрабатываем")
                }
            case .failure(let error):
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    // валидация email
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    // валидация пароля
    static func isValidPassword(_ password: String) -> Bool {
        return password.characters.count > 3
    }
}

