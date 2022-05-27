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
     var first = NumberInputModel(4)
     var second = NumberInputModel(4)
     var result = NumberInputModel(5)
    @State var showCheck = false
    @State var showResult = false
    @State var isRotated = true
    var animation: Animation {
        Animation.linear
            .repeatCount(5, autoreverses: false)
    }
    fileprivate func reset() {
        editable = true
        first.focus = .one
        solving = false
        showCheck = false
        showResult = false
        first.Value=0
        second.Value=0
        result.Value=0
    }
    
    fileprivate func solve() {
        editable.toggle()
        solving.toggle()
        if solving {
            result.focus = Field(rawValue: opt == 2 ? numOfDigit : (numOfDigit+1)) ?? .four
        }
    }
    
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
                        .rotationEffect(Angle.degrees(isRotated ? 30 : 0))
                        .animation(animation,value: isRotated)
                }
                VStack{
                    HStack{
                        Spacer()
                        NumberInputView(text:" ",editable:$editable,firstline: opt == 2 ? 3 : 0 ).frame(alignment: .trailing).environmentObject(first)
                    }.frame(alignment: .trailing).border(Color.red)
                    HStack{
                        Spacer()
                        NumberInputView(text:opt == 2 ? "-" : "+",editable:$editable).frame(alignment: .trailing).environmentObject(second)
                    }.frame(alignment: .trailing).border(Color.red)
                    
                    Divider()
                    HStack{
                        Spacer()
                        NumberInputView(text:"=",editable:$solving,firstline: opt == 2 ? 0 : 1 ,desc: true).frame(alignment: .trailing).environmentObject(result)
                    }.frame(alignment: .trailing).border(Color.red)
                    
                    
                }.frame(width: CGFloat((numOfDigit+4))*50,alignment: .trailing).onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now()+1){
                        first.focus = .one
                    }
                }
                HStack(spacing: 15){
                    Spacer()
                    Button("Solve"){
                        solve()
                    }.buttonStyle(.borderedProminent)
                    Text("Check").tapRecognizer(tapSensitivity: 0.3, singleTapAction: {
                        withAnimation{
                            showCheck.toggle()
                            showResult = false
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.2){withAnimation{
                                isRotated.toggle()}
                            }
                        }
                    }, doubleTapAction: {
                        withAnimation{
                            showResult = true
                            showCheck = true
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.2){withAnimation{
                                isRotated.toggle()}
                            }
                        }
                    }).background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Button("Reset"){
                        reset()
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
                
                Button("自动出题"){
                    let minValue = (10 ^^ (numOfDigit-1)) + 1
                    let maxValue = 10 ^^ numOfDigit
                    let firstValue = Int.random(in: minValue ..< maxValue)
                    let secondValue = opt==2 ? Int.random(in: minValue ..< firstValue) : Int.random(in: minValue ..< maxValue)
                    self.reset()
                    first.Value=firstValue
                    second.Value=secondValue
                    solve()
                }.buttonStyle(.bordered).padding(.vertical)
                
            }.frame(width: 150).padding(10)
        }
    }
}

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

struct DigitMinus_Previews: PreviewProvider {
    static var previews: some View {
        DigitMinusView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
