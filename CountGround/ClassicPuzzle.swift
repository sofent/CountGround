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
    @State var win = false
    var body: some View {
        
        VStack {
            ForEach(0...3,id:\.self){nx in
                HStack {
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
                        Text("拼图成功")
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
                                self.puzzle = puzzle
                            }
                           
                        })
            .onAppear{
                initPuzzle()
            }
            .onChange(of: puzzle){ p in
                            var winArray = Array(1...16)
                            winArray[15] = 0
                            if p == winArray {
                                win = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                    win = false
                                    initPuzzle()
                                }
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
       
        VStack{
                Image(systemName: "\(number).square.fill")
                .resizable().scaledToFit()
                    .font(.largeTitle)
                    .foregroundColor(.brown)
        }.frame(width: size, height: size )
            .opacity(number==0 ? 0 : 1)
    }
    fileprivate func initPuzzle() {
        var puzzle =  Array(1...16)
        puzzle[15] = 0
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
    }
}
