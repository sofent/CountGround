//
//  FourDigitMinus.swift
//  CountGround
//
//  Created by 衡阵 on 2022/4/30.
//
import Foundation
import SwiftUI

enum Opt:Int,CaseIterable{
    case plus = 1
    case minus = 2
}

struct DigitMinusView :View{
    let optText = ["加","减"]
    @State var editable = true
    @State var solving = false
    @State var numOfDigit = 4
    @State var opt = 1
    @ObservedObject var first = NumberInputModel(4)
    @ObservedObject var second = NumberInputModel(4)
    @ObservedObject var result = NumberInputModel(5)
    @State var showCheck = false
    @State var showResult = false
    var body: some View{
        HStack{
            Spacer()
            VStack{
                if showCheck {
                    VStack{
                        if opt == 2{
                            Text( (result.Value == first.Value-second.Value) ? "恭喜你，答对了😊" : "很可惜，答错了😭")
                        }else{
                            Text( (result.Value == first.Value+second.Value) ? "恭喜你，答对了😊" : "很可惜，答错了😭")
                        }
                        
                        if showResult {
                            if opt == 2 {
                                Text("正确答案是:\(first.Value-second.Value)")
                            }else{
                                Text("正确答案是:\(first.Value+second.Value)")
                            }
                            
                        }
                    }.frame(width: CGFloat((numOfDigit+2))*50)
                }
                VStack{
                    HStack{
                        Spacer()
                        NumberInputView(model:first,text:" ",editable:$editable,firstline: opt == 2 ? 3 : 0 ).frame(alignment: .trailing)
                    }.frame(alignment: .trailing).border(Color.red)
                    HStack{
                        Spacer()
                        NumberInputView(model:second,text:opt == 2 ? "-" : "+",editable:$editable).frame(alignment: .trailing)
                    }.frame(alignment: .trailing).border(Color.red)
               
                    Divider()
                    HStack{
                        Spacer()
                        NumberInputView(model:result,text:"=",editable:$solving,firstline: opt == 2 ? 0 : 1 ,desc: true).frame(alignment: .trailing)
                    }.frame(alignment: .trailing).border(Color.red)
                   
                    
                }.frame(width: CGFloat((numOfDigit+4))*50,alignment: .trailing)
                HStack{
                    Spacer()
                    Button("Solve"){
                        editable.toggle()
                        solving.toggle()
                        if solving {
                            result.focus = Field(rawValue: opt == 2 ? numOfDigit : (numOfDigit+1)) ?? .four
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
                    Spacer()
                    
                }.padding(5)
                
            }
            Spacer()
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
                    result.numOfDigit = opt==2 ? newValue : (newValue+1)
                }
                Text("选择位数")
                Picker(selection: $opt) {
                    ForEach(Opt.allCases,id:\.rawValue) { opt in
                        Text(optText[opt.rawValue-1]).tag(opt.rawValue)
                    }
                } label: {
                    Text("选择操作")
                }.onChange(of: opt){newValue in
                    result.numOfDigit = newValue == 1 ? (numOfDigit+1) : numOfDigit
                }
                Text("选择操作")
            }.frame(width: 75).padding(10)
        }
    }
}



struct DigitMinus_Previews: PreviewProvider {
    static var previews: some View {
        DigitMinusView()
    }
}
