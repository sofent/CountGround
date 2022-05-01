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
            VStack(spacing:10){
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
                HStack(spacing: 15){
                    Spacer()
                    Button("Solve"){
                        editable.toggle()
                        solving.toggle()
                        if solving {
                            result.focus = Field(rawValue: opt == 2 ? numOfDigit : (numOfDigit+1)) ?? .four
                        }
                    }.buttonStyle(.borderedProminent)
                    Text("Check").tapRecognizer(tapSensitivity: 0.3, singleTapAction: {
                        showCheck.toggle()
                        showResult = false
                    }, doubleTapAction: {
                        showResult = true
                        showCheck = true
                    }).background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Button("Reset"){
                        editable = true
                        first.focus = .one
                        solving = false
                        showCheck = false
                        showResult = false
                        first.Value=0
                        second.Value=0
                        result.Value=0
                    }.buttonStyle(.borderedProminent)
                    Spacer()
                    
                }.padding(5)
                
            }
            
            Spacer()
            VStack{
                Text("调整位数")
                Stepper("\(numOfDigit)", value: $numOfDigit, in: 1...8)
                
                .onChange(of: numOfDigit){newValue in
                    first.numOfDigit=newValue
                    second.numOfDigit=newValue
                    result.numOfDigit = opt==2 ? newValue : (newValue+1)
                }
                Text("选择操作")
                Picker(selection: $opt) {
                    ForEach(Opt.allCases,id:\.rawValue) { opt in
                        Text(optText[opt.rawValue-1]).tag(opt.rawValue)
                    }
                } label: {
                    Text("选择操作")
                }.pickerStyle(.segmented)
                .onChange(of: opt){newValue in
                    result.numOfDigit = newValue == 1 ? (numOfDigit+1) : numOfDigit
                }
              
            }.frame(width: 150).padding(10)
        }
    }
}



struct DigitMinus_Previews: PreviewProvider {
    static var previews: some View {
        DigitMinusView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
