//
//  NumberInputViewModel.swift
//  CountGround
//
//  Created by 衡阵 on 2022/4/30.
//

import Foundation

class NumberInputModel :ObservableObject{
    var numOfDigit :Int {
        didSet{
            self.values=Array(repeating: "", count: numOfDigit)
        }
    }
    @Published var values :[String]
    @Published var focus:Field?
    var Value: Int {
        get {
            var str = ""
            for v in values {
                str.append(contentsOf: v.isEmpty ? "0" : v)
            }
            return Int(str) ?? 0
        }
        set {
            let t = newValue
            if t == 0 {
                for i in values.indices {
                    values[i] = ""
                }
            }else{
                var unit = 1
                for i in values.indices{
                    values[values.count-i-1] =  String((t/unit)%10)
                    unit=unit*10
                }
            }
        }
    }
    init(_ numOfDigit:Int) {
        self.numOfDigit = numOfDigit
        self.values=Array(repeating: "", count: numOfDigit)
    }
}
