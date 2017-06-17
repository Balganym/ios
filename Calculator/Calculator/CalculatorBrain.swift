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
    private var resultIsPending = false
    private var history = [String]()
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case result
        case clear
    }

    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
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
                if resultIsPending || history.count==0{
                    accumulator = val
                    history.append(symbol)
                    resultIsPending = false
                }
            case .unaryOperation(let function):
                if accumulator == nil, pendingBO != nil {
                    accumulator = pendingBO?.firstOperand
//                    history.append(symbol)
                    history.append(String(describing: accumulator))
                }
                if accumulator != nil{
                    accumulator = function(accumulator!)
                    if history.count > 0, (history[history.count-1] != "="){
                        history.insert(symbol, at: history.count-1)
                        history.insert("(", at: history.count-1)
                        history.append(")")
                    }else if history.count > 0, history[history.count-1] == "="  || history.count == 0 {
                        history.insert("(", at: 0)
                        history.insert(symbol, at: 0)
                        history.insert(")", at: history.count-1)
                    }
                }
                resultIsPending = false
            case .binaryOperation(let function):
                if resultIsPending || (history.count>0 && history[history.count-1] == "=") {
                    history.remove(at: history.count-1)
                }
                if history.count == 0{
                    history.append("0")
                }
                if history.count>2, (symbol == "x" || symbol == "/"), history[history.count-1] != ")"{
                    history.insert("(", at: 0)
                    history.append(")")
                }
                if accumulator != nil {
                    pendingBO = PendingBinaryOperation(function: function,
                                                       firstOperand: pendingBO == nil ? accumulator! : pendingBO!.perform(with: accumulator!))
                    accumulator = nil
                }
                pendingBO?.function = function
                resultIsPending = true
                history.append(symbol)
            case .result:
                if pendingBO != nil, accumulator != nil {
                    if !resultIsPending {
                        history.append(symbol)
                    }
                    accumulator = pendingBO?.perform(with: accumulator!)
                    pendingBO = nil
                }else if accumulator == nil {
                    if !resultIsPending{
                        history.append(symbol)
                    }
                }
            case .clear:
                resultIsPending = false
                accumulator = 0
                pendingBO = nil
                history.removeAll()
            }
        }
    }
    
    // Сетим наш счетчик
    mutating func setOperand(_ operand: Double){
        if history.count > 0, history[history.count-1] == "="{
            history.removeAll()
        }
        resultIsPending = false
        var currentOperand = String(operand)
        if currentOperand.hasSuffix(".0") {
            currentOperand.removeSubrange(currentOperand.index(currentOperand.endIndex, offsetBy: -2)..<currentOperand.endIndex)
        }
        history.append(currentOperand)
        accumulator = operand
    }
    
    var result: (Double?, String?) {
        if resultIsPending {
            return (accumulator, history.joined(separator: " ") + "...")

        }
        return (accumulator, history.joined(separator: " "))
    }
}
