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
    
    mutating func setHistory(_ character: String){
        if history == "0"{
            history = ""
        }
        if history.contains("..."){
            history.removeSubrange(history.index(history.endIndex, offsetBy: -3)..<history.endIndex)
        }else if !resultsPending && history.hasSuffix("= "){
            history = ""
        }
        if !resultsPending{
            history += character
            if character.hasSuffix(".0") {
                history.removeSubrange(history.index(history.endIndex, offsetBy: -2)..<history.endIndex)
            }
            history += " "
        }else{
            history.removeSubrange(history.index(history.endIndex, offsetBy: -2)..<history.endIndex)
            if !history.hasSuffix(") "){
                history.remove(at: history.index(before: history.endIndex))
                history = "(" + history + ") "
            }
            print(history)
            history+=character + " "
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
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let val):
                accumulator = val
                setHistory(symbol)
                history+="..."
            case .unaryOperation(let function):
                if accumulator == nil, pendingBO != nil {
                    accumulator = pendingBO?.firstOperand
                }
                if accumulator != nil{
                    accumulator = function(accumulator!)
                }
                setHistory(symbol)
                history+="..."
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBO = PendingBinaryOperation(function: function,
                                                       firstOperand: pendingBO == nil ? accumulator! : pendingBO!.perform(with: accumulator!))
                    accumulator = nil
                }
                pendingBO?.function = function
                setHistory(symbol)
                history+="..."
            case .result:
                if pendingBO != nil, accumulator != nil {
                    resultsPending = false
                    accumulator = pendingBO?.perform(with: accumulator!)
                    pendingBO = nil
                }
                setHistory(symbol)
            case .clear:
                resultsPending = false
                accumulator = 0
                pendingBO = nil
                history = "0"
            }
            resultsPending = true
        }
    }
    
    // Сетим наш счетчик
    mutating func setOperand(_ operand: Double){
        resultsPending = false
        setHistory(String(operand))
        var currentOperand = String(operand)
        if currentOperand.hasSuffix(".0") {
            currentOperand.removeSubrange(currentOperand.index(currentOperand.endIndex, offsetBy: -2)..<currentOperand.endIndex)
        }
        accumulator = operand
    }
    
    var result: (Double?, String?) {
        return (accumulator, history)
    }
}
