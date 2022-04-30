//
//  FourDigitMinus.swift
//  CountGround
//
//  Created by 衡阵 on 2022/4/30.
//
import Foundation
import SwiftUI
import Combine

enum Field: Hashable {
    case one
    case two
    case three
    case four
}

struct FourDigitMinusView :View{
    @State var editable = true
    @State var solving = false
    @ObservedObject var first = FourDigitModel()
    @ObservedObject var second = FourDigitModel()
    @ObservedObject var result = FourDigitModel()
    @State var showCheck = false
    @State var showResult = false
    var body: some View{
        VStack{
            if showCheck {
                VStack{
                    Text( (result.Value == first.Value-second.Value) ? "恭喜你，答对了😊" : "很可惜，答错了😭")
                    if showResult {
                        Text("正确答案是:\(first.Value-second.Value)")
                    }
                }
            }
            FourDigitView(model:first,text:" ",editable:$editable,firstline: true)
            FourDigitView(model:second,text:"-",editable:$editable)
            Divider()
            FourDigitView(model:result,text:"=",editable:$solving,desc: true)
            HStack{
                Button("Solve"){
                    editable.toggle()
                    solving.toggle()
                    if solving {
                        result.focus = .four
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
    }
}
class FourDigitModel :ObservableObject{
    @Published var m1 :String = ""
    @Published var m2 :String = ""
    @Published var m3 :String = ""
    @Published var m4 :String = ""
    @Published var focus:Field?
    var Value: Int {
        get {
            let str = (!m1.isEmpty ? m1 : "0") + (!m2.isEmpty ? m2 : "0") + (!m3.isEmpty ? m3 : "0") + (!m4.isEmpty ? m4 : "0")
            return Int(str) ?? 0
        }
        set {
            let t = newValue
            if t == 0 {
                m1 = ""
                m2 = ""
                m3 = ""
                m4 = ""
            }else{
                m4 = String(t%10)
                m3 = String((t/10)%10)
                m2 = String((t/100)%10)
                m1 = String((t/1000)%10)
                
            }
        }
    }
}
struct FourDigitView: View {
    @ObservedObject var model :FourDigitModel
  
    @FocusState private var focus: Field?
    let text:String
    @Binding var editable :Bool
    var firstline = false
    var desc = false
    var body: some View {
        
        HStack{
            Text(text).frame(width: 50).font(.headline)
            DigitInputField(index:.one,value:$model.m1,focus:_focus,firstline:firstline,desc: desc,editable: $editable)
            DigitInputField(index:.two,value:$model.m2,focus:_focus,firstline:firstline,desc: desc,editable: $editable)
            DigitInputField(index:.three,value:$model.m3,focus:_focus,firstline:firstline,desc: desc,editable: $editable)
            DigitInputField(index:.four,value:$model.m4,focus:_focus,firstline:firstline,desc: desc,editable: $editable)
        }.padding().synchronize($model.focus,$focus)
        
        
    }
    
}

struct DigitInputField:View{
    let index :Field
    @Binding var value:String
    @FocusState var focus:Field?
    @State var leftValue:String=""
    var firstline = false
    var desc = false
    @State var borrow = false
    @Binding var editable :Bool
    @State var oldvalue = ""
    var body: some View {
        VStack{
            if firstline && !editable {
                Text(borrow ? "①" : "•").foregroundColor(borrow ? Color.red : Color.black).onTapGesture {
                    if value == ""{
                        return
                    }
                    borrow.toggle()
                    if borrow {
                        let nv = (Int(value) ?? 0)-1
                        self.leftValue = String(nv)
                    }else{
                        self.leftValue = ""
                    }
                    
                }.font(.subheadline)
                
            }
            TextField("", text: $value)
                .font(.largeTitle)
                .border(Color.blue)
                .frame(width: 50, alignment: .center)
                .focused($focus, equals: index)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .onReceive(Just(value)) { newValue in
                    var filtered = newValue.filter { "0123456789".contains($0) }
                    //use new input number
                    filtered = String(filtered.suffix(1))
                    if oldvalue != filtered{
                        self.oldvalue = filtered
                        if !filtered.isEmpty {
                            switch index {
                            case .one:
                                focus = desc ? nil : .two
                            case .two:
                                focus = desc ? .one : .three
                            case .three:
                                focus = desc ? .two : .four
                            case .four:
                                focus = desc ? .three : nil
                                break
                            }
                        }
                    }
                    if filtered != newValue {
                        self.value = filtered
                        
                    }}.onChange(of: value){
                        newValue in
                        if newValue == "" {
                            self.leftValue = ""
                            self.borrow = false
                        }
                    }
                    .disabled(!editable)
            if firstline && !editable  {
                Text("\(leftValue)")
                
            }
        }
        .onAppear{
            if firstline {
                DispatchQueue.main.asyncAfter(deadline: .now()+1){
                    self.focus = .one
                }}
        }
    }
}

struct FourDigitMinus_Previews: PreviewProvider {
    static var previews: some View {
        FourDigitMinusView()
    }
}
