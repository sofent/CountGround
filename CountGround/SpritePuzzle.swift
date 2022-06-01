//
//  SpritePuzzle.swift
//  CountGround
//
//  Created by sofent on 2022/5/31.
//

import SwiftUI
import SpriteKit

struct SpritePuzzle: View {
   
    
    var body: some View {
        GeometryReader{ proxy in
            let size = min(proxy.size.height,proxy.size.width)
           
           
            SpriteView(scene: createScene(size))
                .frame(width: size, height: size).offset(x: (proxy.size.width-size)/2, y: (proxy.size.height-size)/2)
        }
    }
    
    func createScene(_ size:CGFloat)->GameScene {
        let scene = GameScene(size: CGSize(width: size, height: size))
        return scene
    }
}

struct SpritePuzzle_Previews: PreviewProvider {
    static var previews: some View {
        SpritePuzzle()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
