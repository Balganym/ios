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
    private var accumulatorString: String? = ""
    private var resultIsPending = false
    private var resultIsClicked = false
    private var history = [String]()
    
    // Преобразование числа в строку
    func toString(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumSignificantDigits = 6
        return formatter.string(from: number as NSNumber)!
    }
    
    // очень часто используемая запись в кейсах (просто, чтобы каждый раз не писать одно и то же)
    mutating func setFalseAndSetAccumulatorString(_ addToHistory: String){
        resultIsPending = false
        resultIsClicked = false
        accumulatorString = addToHistory
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double,String) -> (Double, String))
        case binaryOperation((Double, Double) -> Double)
        case random
        case result
        case clear
    }
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation({(sqrt($0), "√(" + ($1) + ")")}),
        "cos": Operation.unaryOperation {(cos($0), "cos(" + $1 + ")")},
        "sin": Operation.unaryOperation {(sin($0), "sin(" + $1 + ")")},
        "tan": Operation.unaryOperation {(tan($0), "tan(" + $1 + ")")},
        "ln": Operation.unaryOperation {(log($0), "ln(" + $1 + ")")},
        "%": Operation.unaryOperation {(($0/100), "(" + $1 + "/100)")},
        "±": Operation.unaryOperation {(-$0, "-(" + $1 + ")")},
        "x^2": Operation.unaryOperation {($0 * $0, "(" + $1 + ")^2")},
        "x^3": Operation.unaryOperation {($0 * $0 * $0, "(" + $1 + ")^3")},
        "1/x": Operation.unaryOperation {(1/$0, "1/(" + $1 + ")")},
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "/": Operation.binaryOperation(/),
        "rand": Operation.random,
        "AC": Operation.clear,
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
                if !resultIsPending && history.count > 0{
                    history.remove(at: history.count - 1)
                }
                accumulator = val
                history.append(symbol)
                setFalseAndSetAccumulatorString(symbol)
            case .unaryOperation(let function):
                if !resultIsPending, history.count > 0 {
                    history.remove(at: history.count - 1)
                }
                if accumulator == nil, pendingBO != nil {
                    accumulator = pendingBO?.firstOperand
                    if accumulatorString == "" {
                        accumulatorString = toString(accumulator!)
                    }
                }
                if accumulator != nil{
                    if accumulatorString == ""{
                        accumulatorString = toString(accumulator!)
                    }else if history.count>0, accumulatorString == history[history.count - 1]{
                        history.remove(at: history.count - 1)
                    }
                    let result = function(accumulator!, accumulatorString!)
                    accumulator = result.0
                    accumulatorString = result.1
                    history.append(accumulatorString!)
                }
                resultIsPending = false
            case .binaryOperation(let function):
                resultIsClicked = false
                if resultIsPending {
                    history.remove(at: history.count - 1)
                }
                accumulatorString = history.joined(separator: " ")
                if history.count == 0{
                    history.append("0")
                }
                if history.count>2, (symbol == "×" || symbol == "/"), history[history.count-1] != ")"{
                    accumulatorString = history.joined(separator: " ")
                    history.removeAll()
                    history.append(accumulatorString!)
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
            case .random:
                accumulator = (Double(arc4random_uniform(101)) / 100.0)
                if !resultIsPending && history.count > 0{
                    history.remove(at: history.count - 1)
                }
                setFalseAndSetAccumulatorString(toString(accumulator!))
                history.append(accumulatorString!)
            case .result:
                if pendingBO != nil, accumulator != nil {
                    resultIsClicked = true
                    resultIsPending = false
                    if !resultIsPending {
                        accumulatorString = history.joined(separator: " ")
                        history.removeAll()
                        history.append(accumulatorString!)
                    }
                    accumulator = pendingBO?.perform(with: accumulator!)
                    pendingBO = nil
                }else if accumulator == nil {
                    resultIsClicked = true
                    if !resultIsPending{
                        accumulatorString = history.joined(separator: " ")
                        history.removeAll()
                        history.append(accumulatorString!)
                    }
                }
            case .clear:
                accumulator = 0
                pendingBO = nil
                history.removeAll()
                setFalseAndSetAccumulatorString("")
            }
        }
    }
    
    // закачивание операнда в модельку
    mutating func setOperand(_ operand: Double){
        if resultIsClicked || (!resultIsPending && history.count != 0){
            history.removeAll()
            pendingBO = nil
        }
        setFalseAndSetAccumulatorString(toString(operand))
        history.append(accumulatorString!)
        accumulator = operand
    }
    
    // возвращаем результат и историю
    var result: (Double?, String?) {
        if resultIsPending{
            return (accumulator, history.joined(separator: " ") + "...")
        }else if resultIsClicked {
            return (accumulator, history.joined(separator: " ") + " =")
        }
        return (accumulator, history.joined(separator: " "))
    }
}
