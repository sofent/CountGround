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
    var snodePos = CGPoint.zero
    var shape = SKShapeNode()
    var model :PuzzleModel
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize,model:PuzzleModel) {
        self.model = model
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
        model.initPuzzle()
        let nodeSize = CGSize(width: (shape.frame.size.width-20)/4, height: (shape.frame.size.height-20)/4)
        shape.removeAllChildren()
        (0...3).forEach{ x in
            (0...3).forEach{ y in
                let config = UIImage.SymbolConfiguration(pointSize: nodeSize.width, weight: .bold)
                var image = UIImage(systemName: "\(model.puzzle[x+4*y]).square.fill",withConfiguration: config)!
                image = image.withColor(.brown)
                
                let txt = SKTexture(image: image)
                let node = SKSpriteNode(texture: txt)
                node.size = nodeSize
                node.position = CGPoint(x: nodeSize.width*(CGFloat(x)+0.5)+10, y: nodeSize.height*(CGFloat(3-y)+0.5)+10)
                node.name = "\(model.puzzle[x+4*y])"
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
    
   
    
    private func setUpAudio() {
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedNode = SKNode()
        if let touch = touches.first {
            let p = touch.location(in: self)
             let n = atPoint(p)
                if let name=n.name,name != "background"{
                    if n != zeroNode && (n.position-zeroNode.position).length() < (CGPoint(x: zeroNode.frame.width, y: zeroNode.frame.height).length()) - 1 {
                        //print( abs(n.position.x-zeroNode.position.x),abs(n.position.y-zeroNode.position.y) )
                        selectedNode = n
                        snodePos = p
                        selectedNode.removeAllActions()
                        let sequence = SKAction.sequence([SKAction.rotate(byAngle: degToRad(degree: -4.0), duration: 0.1),
                                                          SKAction.rotate(byAngle: 0.0, duration: 0.1),
                                                          SKAction.rotate(byAngle: degToRad(degree: 4.0), duration: 0.1)])
                        selectedNode.run(SKAction.repeatForever(sequence))
                    }
                }
            }
        
    }
    
    func degToRad(degree: Double) -> CGFloat {
        return CGFloat(degree / 180.0 * .pi)
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
        selectedNode.removeAllActions()
        selectedNode.run(SKAction.rotate(toAngle: 0.0, duration: 0.1))
        if selectedNode.name == nil {
            return
        }
        if let touch = touches.first {
            let p = touch.location(in: self)
            let direction = (zeroNode.position - selectedNode.position).normalized()
            let moveDirction = (p-snodePos).normalized()
            let cosine = (moveDirction.x*direction.x+direction.y*moveDirction.y)/(direction.length()*moveDirction.length())
            if  cosine > 0 || (p-snodePos).length() < 3{
                let snodeMove = SKAction.move(to: zeroNode.position, duration: 0.1)
                let znodeMove = SKAction.move(to: selectedNode.position, duration: 0.1)
                selectedNode.run(snodeMove)
                zeroNode.removeAllActions()
                zeroNode.run(znodeMove)
                //zeroNode.position = np
                model.swap(model.puzzle.firstIndex(of: 0)!,model.puzzle.firstIndex(of: Int(selectedNode.name!)!)!)
                if model.win {
                    let loseAction = SKAction.run() { [weak self] in
                        guard let `self` = self else { return }
                        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                        let gameOverScene = GameOverScene(size: self.size,model: self.model)
                        self.view?.presentScene(gameOverScene, transition: reveal)
                    }
                    self.run(loseAction)
                    
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

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *(point: CGPoint, point2: CGPoint) -> CGPoint {
    return CGPoint(x: point.x * point2.x, y: point.y * point2.y)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}


extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}


class GameOverScene: SKScene {
    var model:PuzzleModel
    init(size: CGSize,model:PuzzleModel) {
        self.model = model
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
                let scene = GameScene(size: size,model: self.model)
                self.view?.presentScene(scene, transition:reveal)
            }
        ]))
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

