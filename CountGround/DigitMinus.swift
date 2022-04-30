//
//  FourDigitMinus.swift
//  CountGround
//
//  Created by 衡阵 on 2022/4/30.
//
import Foundation
import SwiftUI



struct DigitMinusView :View{
    @State var editable = true
    @State var solving = false
    @State var numOfDigit = 4
    @ObservedObject var first = NumberInputModel(4)
    @ObservedObject var second = NumberInputModel(4)
    @ObservedObject var result = NumberInputModel(4)
    @State var showCheck = false
    @State var showResult = false
    var body: some View{
        HStack{
            VStack{
                if showCheck {
                    VStack{
                        Text( (result.Value == first.Value-second.Value) ? "恭喜你，答对了😊" : "很可惜，答错了😭")
                        if showResult {
                            Text("正确答案是:\(first.Value-second.Value)")
                        }
                    }
                }
                NumberInputView(model:first,text:" ",editable:$editable,firstline: true)
                NumberInputView(model:second,text:"-",editable:$editable)
                Divider()
                NumberInputView(model:result,text:"=",editable:$solving,desc: true)
                HStack{
                    Button("Solve"){
                        editable.toggle()
                        solving.toggle()
                        if solving {
                            result.focus = Field(rawValue: numOfDigit) ?? .four
                        }
                    }.padding()
                    Text("Check").tapRecognizer(tapSensitivity: 0.3, singleTapAction: {
                        showCheck.toggle()
                        showResult = false
                    }, doubleTapAction: {
                        showResult = true
                        showCheck = true
                    }).padding()
                    Button("Reset"){
                        editable = true
                        first.focus = .one
                        solving = false
                        showCheck = false
                        showResult = false
                        first.Value=0
                        second.Value=0
                        result.Value=0
                    }.padding()
                    
                }.padding(5)
                
            }
            VStack{
               
                Picker(selection: $numOfDigit) {
                    ForEach(Field.allCases,id:\.rawValue) { field in
                        Text(String(field.rawValue)).tag(field.rawValue)
                    }
                } label: {
                    Text("选择位数")
                }
                .onChange(of: numOfDigit){newValue in
                    first.numOfDigit=newValue
                    second.numOfDigit=newValue
                    result.numOfDigit=newValue
                }
                Text("选择位数")
            }.frame(width: 75)
        }
    }
}



struct DigitMinus_Previews: PreviewProvider {
    static var previews: some View {
        DigitMinusView()
    }
}
