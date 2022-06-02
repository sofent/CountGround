//
//  ClassicPuzzle.swift
//  CountGround
//
//  Created by 衡阵 on 2022/5/29.
//

import SwiftUI



struct ClassicPuzzle: View {
    let useSprite :Bool
    
    @ObservedObject var model = PuzzleModel()
    var body: some View {
        
        HStack {
            Spacer()
            VStack {
                if !model.win && model.starDate != .distantPast {
                    TimelineView(.periodic(from:.now, by: 1.0)) { context in
                        Text("已耗时:\(Int(context.date.timeIntervalSince(model.starDate).rounded()))秒")
                    }
                }else{
                    Text("未在计时")
                }
                if useSprite {
                    SpritePuzzle().environmentObject(model)
                }else{
                    SwiftPuzzleView().environmentObject(model)
                }
            }.onChange(of: model.tail){ _ in
                model.initPuzzle()
            }
            
            Spacer()
            VStack(spacing:10){
                if model.image != nil {
                    Image(uiImage: model.image!.toSquare())
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                }
                Button("选择图片"){
                    self.model.showImagePicker = true
                }.buttonStyle(.borderedProminent).padding(.vertical)
                Button("重新开始"){
                    model.initPuzzle()
                }.buttonStyle(.borderedProminent).padding(.vertical)
                Button("清除图片"){
                    self.model.image = nil
                    model.initPuzzle()
                }.buttonStyle(.borderedProminent).padding(.vertical)
                    .disabled(self.model.image==nil)
                Toggle("",isOn:$model.tail).frame(width: 80)
                Text(model.tail ? "尾部空格":"头部空格")
            }.padding(.horizontal)
        }
        .sheet(isPresented: $model.showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { image in
                self.model.image = image.fixedOrientation()
                model.initPuzzle()
            }
        }
    }
    
   
    
    
   
    
}



struct ClassicPuzzle_Previews: PreviewProvider {
    static var previews: some View {
        ClassicPuzzle(useSprite: false)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
