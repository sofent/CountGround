//
//  NumberInputView.swift
//  CountGround
//
//  Created by 衡阵 on 2022/4/30.
//
import SwiftUI
import Combine


enum Field:Int,CaseIterable {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
}

struct NumberInputView: View {
    @EnvironmentObject var model :NumberInputModel
  
    @FocusState private var focus: Field?
    let text:String
    @Binding var editable :Bool
    var firstline = 0
    var desc = false
    
    
    
    var body: some View {
        
        HStack{
            Text(text).frame(width: 50).font(.headline)
            ForEach(model.values.indices,id:\.self){
                i in
                let f=Field(rawValue: i+1) ?? .one
                DigitInputField(numOfDigit:model.numOfDigit,index:f,value:$model.values[i],focus:_focus,firstline:firstline,desc: desc,editable: $editable)
                
            }
        }
        .padding().synchronize($model.focus,$focus)
        
        
    }
    
}

struct DigitInputField:View{
    var numOfDigit :Int
    let index :Field
    @Binding var value:String
    @FocusState var focus:Field?
    @State var leftValue:String=""
    var firstline = 0
    var desc = false
    @State var borrow = false
    @Binding var editable :Bool
    @State var oldvalue = ""
    var body: some View {
        VStack{
            if (firstline == 3 && !editable) || (firstline == 1 && editable) {
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
                            let next = desc ? (index.rawValue - 1) : (index.rawValue + 1)
                            focus = Field(rawValue: next)
                            
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
                    .disabled(!editable).textSelection(.disabled)
            if (firstline&0x2) != 0 && !editable  {
                Text("\(leftValue)")
                
            }
        }
    }
}
