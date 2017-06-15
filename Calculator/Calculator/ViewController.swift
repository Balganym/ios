//
//  ViewController.swift
//  Calculator
//
//  Created by mac on 13.06.17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel?
    @IBOutlet weak var historyDisplay: UILabel!
    
    var userInTheMiddleOfTyping = false
    var pointExist = false
    
    //Вывод на дисплей
    var displayValue: Double {
        get {return Double(display!.text!)!}
        set {
            var curValue = String(newValue)
            print(userInTheMiddleOfTyping)
            if curValue.hasSuffix(".0") {
                curValue.removeSubrange(curValue.index(curValue.endIndex, offsetBy: -2)..<curValue.endIndex)
            }
            display!.text = curValue
        }
    }
    
    //Проверка ввода/вывода числа с плавающей точкой
    @IBAction func setFloatingPoint(_ sender: UIButton) {
        if !pointExist, userInTheMiddleOfTyping{
            display!.text! += sender.currentTitle!
            pointExist = true
            userInTheMiddleOfTyping = true
        }
        else{
            display!.text! = "0" + sender.currentTitle!
            pointExist = true
            userInTheMiddleOfTyping = true
        }
    }
    
    //Ввод числа
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userInTheMiddleOfTyping{
            let textCurrentlyInDisplay = display!.text!
            display!.text = textCurrentlyInDisplay + digit
        }else{
            display!.text = digit
            userInTheMiddleOfTyping = true
            pointExist = false
        }
    }
    
    
    private var brain = CalculatorBarain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userInTheMiddleOfTyping{
            brain.setOperand(displayValue)
            userInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle{
            brain.performOperation(mathematicalSymbol);
        }
        if let result = brain.result.0{
            displayValue = result
        }
        if let history = brain.result.1{
            historyDisplay!.text! = history
        }
        
    }
}
