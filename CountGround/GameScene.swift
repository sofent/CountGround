//
//  GameScene.swift
//  CountGround
//
//  Created by sofent on 2022/5/31.
//

import SpriteKit


class GameScene: SKScene {
    let background = SKSpriteNode(imageNamed: "backgroud")
    var zeroNode = SKNode()
    var selectedNode = SKNode()
    var puzzle =  Array(1...16)
    var shape = SKShapeNode()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        super.scaleMode = .aspectFill
        // 1
        self.background.name = "background"
        self.background.scale(to: size)
        self.background.anchorPoint = .zero
        self.background.zPosition = -1
      
        // 2
        self.addChild(background)
        let  shapeSize = CGSize(width: size.width*0.8, height: size.width*0.8)
        let shape = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: shapeSize))
        shape.lineWidth = 5
        shape.strokeColor = .blue
        print(size)
        shape.position = CGPoint(x: (size.width-shapeSize.width)/2,y: (size.height-shapeSize.width)/2)
        self.shape=shape
        addChild(shape)
       
       
        
    }
    
    override func didMove(to view: SKView) {
        view.showsPhysics = true
        physicsWorld.contactDelegate = self
        setUpAudio()
        initPuzzle()
    }
    
    func initPuzzle(){
        var puzzle =  Array(1...16)
        puzzle[15] = 0
       
        for _ in 1...128 {
            let index = Int.random(in: 0...3)
            move(Direction.allCases[index], puzzle: &puzzle)
        }
        self.puzzle = puzzle
        let nodeSize = CGSize(width: (shape.frame.size.width-20)/4, height: (shape.frame.size.height-20)/4)
        shape.removeAllChildren()
        (0...3).forEach{ x in
            (0...3).forEach{ y in
                let config = UIImage.SymbolConfiguration(pointSize: nodeSize.width, weight: .bold)
                var image = UIImage(systemName: "\(puzzle[x+4*y]).square.fill",withConfiguration: config)!
                image = image.withColor(.brown)
                
                let txt = SKTexture(image: image)
                let node = SKSpriteNode(texture: txt)
                node.size = nodeSize
                node.position = CGPoint(x: nodeSize.width*(CGFloat(x)+0.5)+10, y: nodeSize.height*(CGFloat(3-y)+0.5)+10)
                node.name = "\(puzzle[x+4*y])"
                node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                node.physicsBody?.isDynamic=false
                shape.addChild(node)
                if node.name=="0"{
                    node.alpha = 0.01
                    self.zeroNode=node
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
    
    private func setUpAudio() {
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedNode = SKNode()
        for touch in touches {
            let p = touch.location(in: self)
            self.nodes(at: p).forEach{ n in
                if let name=n.name,name != "background"{
                    if n != zeroNode && abs(n.position.x-zeroNode.position.x) < (n.frame.width+1) && abs(n.position.y-zeroNode.position.y) < (n.frame.height+1) && (n.position.x == zeroNode.position.x || n.position.y == zeroNode.position.y){
                        print( abs(n.position.x-zeroNode.position.x),abs(n.position.y-zeroNode.position.y) )
                        selectedNode = n
                       
                    }
                }
            }
        }
    }
    
   /* override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let p = touch.location(in: self)
            self.nodes(at: p).forEach{ n in
                if let name=n.name,name != "background"{
                    if n != zeroNode {
                        selectedNode = n
                    }
                }
            }
        }
    }*/
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let p = touch.location(in: self)
            self.nodes(at: p).forEach{ n in
                if n == zeroNode && selectedNode.name != nil {
                    let np = selectedNode.position
                    selectedNode.position = zeroNode.position
                    zeroNode.position = np
                    puzzle.swapAt(puzzle.firstIndex(of: 0)!,puzzle.firstIndex(of: Int(selectedNode.name!)!)!)
                    var answer = Array(1...16)
                    answer[15] = 0
                    print(puzzle)
                    if puzzle == answer {
                        let loseAction = SKAction.run() { [weak self] in
                            guard let `self` = self else { return }
                            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                            let gameOverScene = GameOverScene(size: self.size)
                            self.view?.presentScene(gameOverScene, transition: reveal)
                        }
                        self.run(loseAction)
                        
                    }
                }
            }
        }
    }
    
    
}

extension GameScene: SKPhysicsContactDelegate {
  override func update(_ currentTime: TimeInterval) {
    
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
      if contact.bodyA.node == selectedNode || contact.bodyB.node == selectedNode{
          
      }
    }
}

class GameOverScene: SKScene {
    override init(size: CGSize) {
    super.init(size: size)
    
    // 1
        backgroundColor = SKColor.systemPink
    
    // 2
    let message = "You Won!"
    
    // 3
    let label = SKLabelNode(fontNamed: "Chalkduster")
    label.text = message
    label.fontSize = 40
    label.fontColor = SKColor.black
    label.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(label)
    
    // 4
    run(SKAction.sequence([
      SKAction.wait(forDuration: 3.0),
      SKAction.run() { [weak self] in
        // 5
        guard let `self` = self else { return }
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameScene(size: size)
        self.view?.presentScene(scene, transition:reveal)
      }
      ]))
  }
  
  // 6
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

