//
//  PuzzleModel.swift
//  CountGround
//
//  Created by 衡阵 on 2022/6/2.
//

import Foundation
import UIKit
import SwiftUI


enum Direction:CaseIterable {
    case up
    case down
    case left
    case right
}

class PuzzleModel:ObservableObject{
    @Published var puzzle:[Int] = Array(1...16)
    @Published var image :UIImage?
    @Published var puzzleImages:[UIImage] = [UIImage].init(repeating: UIImage(), count: 16)
    @Published var win = false
    @Published var showImagePicker = false
    @Published var starDate : Date = .distantPast
    @AppStorage("tail") var tail = true
    
    func initPuzzle() {
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
    func move(_ dir:Direction){
        var puzzle = self.puzzle
        self.move(dir,puzzle: &puzzle)
        if puzzle != self.puzzle {
            if starDate == .distantPast{
                starDate = .now
            }
            self.puzzle = puzzle
            var winArray = Array(1...16)
            winArray[tail ? 15:0] = 0
            if self.puzzle == winArray {
                win = true
            }
        }
    }
    
    fileprivate func move(_ dir:Direction,  puzzle:inout [Int]){
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
}
