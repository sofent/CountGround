//
//  SwiftPuzzleView.swift
//  CountGround
//
//  Created by 衡阵 on 2022/6/2.
//

import SwiftUI

struct SwiftPuzzleView: View {
    let size = (min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)*0.8 - 80) / 4
    @EnvironmentObject var model:PuzzleModel
    var body: some View {
        VStack(spacing:1) {
            ForEach(0...3,id:\.self){nx in
                HStack(spacing:1) {
                    ForEach(0...3,id:\.self){ny in
                        CellView(number: model.puzzle[(nx*4)+ny])
                    }
                }
            }
        }.padding()
            .border(.purple,width: 5)
            .blur(radius: model.win ? 5 : 0)
            .overlay{
                if model.win {
                    VStack{
                        Text("拼图成功\n共耗时:\(Int(Date.now.timeIntervalSince(model.starDate).rounded()))秒")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.blue)
                            .font(.title.bold())
                            .padding()
                    }
                    .background(.ultraThinMaterial,in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                .onEnded { value in
                    
                    let horizontalAmount = value.translation.width as CGFloat
                    let verticalAmount = value.translation.height as CGFloat
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        print(horizontalAmount < 0 ? "left swipe" : "right swipe")
                        model.move(horizontalAmount < 0 ? .left : .right)
                    } else {
                        print(verticalAmount < 0 ? "up swipe" : "down swipe")
                        model.move(verticalAmount < 0 ? .up : .down)
                    }
                    
                    
                })
            .onAppear{
                model.initPuzzle()
            }
            .onChange(of: model.tail){ _ in
                model.initPuzzle()
            }
    }
    
    @ViewBuilder func CellView(number:Int)->some View{
        
        VStack(spacing:0){
            if model.image != nil {
                Image(uiImage: number == 0 ? model.puzzleImages[model.tail ? 15:0] : model.puzzleImages [number - 1])
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipped()
            }else{
                Image(systemName: "\(number).square.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.brown)
            }
        }.frame(width: size, height: size )
            .opacity(number==0 ? 0 : 1)
    }
}

struct SwiftPuzzleView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftPuzzleView().environmentObject(PuzzleModel())
    }
}
