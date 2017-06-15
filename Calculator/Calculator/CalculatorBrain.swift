//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by mac on 13.06.17.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation

struct CalculatorBarain{
    
    private var accumulator: Double? = 0
    private var resultsPending = false
    private var history = ""
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case result
        case clear
    }
    
    mutating func setHistory(){
        if resultsPending {
            history.removeSubrange(history.index(history.endIndex, offsetBy: -4)..<history.endIndex)
        }
        else {
            resultsPending = true
        }
    }
    
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "+/-": Operation.unaryOperation {-$0},
        "1/x": Operation.unaryOperation {1/$0},
        "%": Operation.unaryOperation {$0/100},
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "x": Operation.binaryOperation(*),
        "/": Operation.binaryOperation(/),
        "AC": Operation.clear,
        "rand": Operation.constant(Double(arc4random_uniform(100))/100),
        "=": Operation.result,
    ]
    
    // Выполнение бинарных операций
    private struct PendingBinaryOperation{
        var function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double  {
            return function(firstOperand, secondOperand)
        }
    }
    
    private var pendingBO: PendingBinaryOperation?
    
    mutating func performOperation(_ symbol: String){
        setHistory()
        history += " " + symbol + "..."
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let val):
                accumulator = val
            case .unaryOperation(let function):
                if accumulator == nil, pendingBO != nil {
                    accumulator = pendingBO?.firstOperand
                }
                if accumulator != nil{
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBO = PendingBinaryOperation(function: function,
                                                       firstOperand: pendingBO == nil ? accumulator! : pendingBO!.perform(with: accumulator!))
                    accumulator = nil
                }
                pendingBO?.function = function
            case .result:
                if pendingBO != nil, accumulator != nil {
                    accumulator = pendingBO?.perform(with: accumulator!)
                    pendingBO = nil
                    history.removeSubrange(history.index(history.endIndex, offsetBy: -3)..<history.endIndex)
                    history += " "
                }
                
            case .clear:
                accumulator = 0
                pendingBO = nil
                history = ""
            }
        }
    }
    
    // Сетим наш счетчик
    mutating func setOperand(_ operand: Double){
        if resultsPending {
             history.removeSubrange(history.index(history.endIndex, offsetBy: -3)..<history.endIndex)
        }
        resultsPending = false
        var currentOperand = String(operand)
        if currentOperand.hasSuffix(".0") {
            currentOperand.removeSubrange(currentOperand.index(currentOperand.endIndex, offsetBy: -2)..<currentOperand.endIndex)
        }
        history = history == "0" ? currentOperand : history + " " + currentOperand
        accumulator = operand
    }
    
    var result: (Double?, String?) {
        return (accumulator, history)
    }
    
}
