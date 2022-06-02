//
//  ClassicPuzzle.swift
//  CountGround
//
//  Created by 衡阵 on 2022/5/29.
//

import SwiftUI

enum Direction:CaseIterable {
    case up
    case down
    case left
    case right
}

struct ClassicPuzzle: View {
    let size = (min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)*0.8 - 80) / 4
    @State var puzzle:[Int] = Array(1...16)
    @State var image :UIImage?
    @State var puzzleImages:[UIImage] = [UIImage].init(repeating: UIImage(), count: 16)
    @State var win = false
    @State var showImagePicker = false
    @State var starDate : Date = .distantPast
    @AppStorage("tail") var tail = true
    var body: some View {
        
        HStack {
            Spacer()
            VStack {
                if !win && starDate != .distantPast {
                    TimelineView(.periodic(from:.now, by: 1.0)) { context in
                        Text("已耗时:\(Int(context.date.timeIntervalSince(starDate).rounded()))秒")
                    }
                }else{
                    Text("未在计时")
                }
                VStack(spacing:1) {
                    ForEach(0...3,id:\.self){nx in
                        HStack(spacing:1) {
                            ForEach(0...3,id:\.self){ny in
                                CellView(number: puzzle[(nx*4)+ny])
                            }
                        }
                    }
                }.padding()
                    .border(.purple,width: 5)
                    .blur(radius: win ? 5 : 0)
                    .overlay{
                        if win {
                            VStack{
                                Text("拼图成功\n共耗时:\(Int(Date.now.timeIntervalSince(starDate).rounded()))秒")
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
                            var puzzle = self.puzzle
                            if abs(horizontalAmount) > abs(verticalAmount) {
                                print(horizontalAmount < 0 ? "left swipe" : "right swipe")
                                move(horizontalAmount < 0 ? .left : .right,puzzle: &puzzle)
                            } else {
                                print(verticalAmount < 0 ? "up swipe" : "down swipe")
                                move(verticalAmount < 0 ? .up : .down,puzzle: &puzzle)
                            }
                            if puzzle != self.puzzle {
                                if starDate == .distantPast{
                                    starDate = .now
                                }
                                self.puzzle = puzzle
                            }
                            
                        })
                    .onAppear{
                        initPuzzle()
                    }
                    .onChange(of: puzzle){ p in
                        var winArray = Array(1...16)
                        winArray[tail ? 15:0] = 0
                        if p == winArray {
                            win = true
                        }
                    }.onChange(of: tail){ _ in
                        initPuzzle()
                    }
            }
            Spacer()
            VStack(spacing:10){
                if image != nil {
                    Image(uiImage: image!.toSquare())
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                }
                Button("选择图片"){
                    self.showImagePicker = true
                }.buttonStyle(.borderedProminent).padding(.vertical)
                Button("重新开始"){
                    initPuzzle()
                }.buttonStyle(.borderedProminent).padding(.vertical)
                Button("清除图片"){
                    self.image = nil
                    initPuzzle()
                }.buttonStyle(.borderedProminent).padding(.vertical)
                    .disabled(self.image==nil)
                Toggle("",isOn:$tail).frame(width: 80)
                Text(tail ? "尾部空格":"头部空格")
            }.padding(.horizontal)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { image in
                self.image = image.fixedOrientation()
                initPuzzle()
            }
        }
    }
    
    func move(_ dir:Direction,  puzzle:inout [Int]){
        let zeroindex = puzzle.firstIndex(of: 0)!
        switch dir {
        case .up,.down:
            let destIndex = dir == .up ? zeroindex + 4 : zeroindex - 4
            if destIndex >= 0 && destIndex <= 15 {
                puzzle.swapAt(zeroindex, destIndex)
            }
        case .left:
            if (zeroindex % 4) != 3 {
                puzzle.swapAt(zeroindex, zeroindex+1)
            }
        case .right:
            if (zeroindex % 4) != 0 {
                puzzle.swapAt(zeroindex, zeroindex-1)
            }
        }
    }
    
    @ViewBuilder func CellView(number:Int)->some View{
        
        VStack(spacing:0){
            if image != nil {
                Image(uiImage: number == 0 ? puzzleImages[tail ? 15:0] : puzzleImages [number - 1])
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
    fileprivate func initPuzzle() {
        starDate = .distantPast
        win = false
        var puzzle =  Array(1...16)
        if let image = image {
            self.puzzleImages = image.toSquare().matrix(4, 4)
        }
        puzzle[tail ? 15:0] = 0
       
        for _ in 1...128 {
            let index = Int.random(in: 0...3)
            move(Direction.allCases[index], puzzle: &puzzle)
        }
        
        
        print(puzzle)
        self.puzzle = puzzle
    }
    
}



struct ClassicPuzzle_Previews: PreviewProvider {
    static var previews: some View {
        ClassicPuzzle()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
