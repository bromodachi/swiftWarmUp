//
//  GameScene.swift
//  Pachinko
//
//  Created by a on 12/1/15.
//  Copyright (c) 2015 bromodachi. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            }
            else {
                editLabel.text = "Edit"
            }
        }
    }
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x:512, y:384)
        background.blendMode = .Replace
        background.zPosition = -1
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        physicsWorld.contactDelegate = self
        addBouncers(CGPoint(x: 0, y: 0))
        addBouncers(CGPoint(x: 256, y: 0))
        addBouncers(CGPoint(x: 512, y: 0))
        addBouncers(CGPoint(x: 768, y: 0))
        addBouncers(CGPoint(x: 1024, y: 0))
        makeSlot(CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(CGPoint(x: 896, y: 0), isGood: false)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.position = CGPoint(x: 980, y:700)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y:700)
        
        createRandomBumpers()
        addChild(scoreLabel)
        addChild(editLabel)
        
        
        
    }
    
    func makeSlot(position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow:SKSpriteNode
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "Good"
        }
        else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "Bad"
        }
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOfSize: slotBase.size)
        slotBase.physicsBody!.dynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 10)
        let spinForever = SKAction.repeatActionForever(spin)
        slotGlow.runAction(spinForever)
    }
    
    func createRandomBumpers() {
        var counter = 0
        var x = 68
        var xSecond = 98
        while counter  != 15 {
            
            createInitalBoxes(CGPoint(x: x, y: 120))
            createInitalBoxes(CGPoint(x: xSecond, y: 180))
            createInitalBoxes(CGPoint(x: x, y: 240))
            x += 60
            xSecond += 60
            counter++
        }
        for index in 0...10 {
            createBumpers (randomCGPoint())
        }
        
    }
    
    func createInitalBoxes  (location: CGPoint) {
        let box = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 15, height: 15))
        box.position = location
        box.physicsBody = SKPhysicsBody(circleOfRadius: box.size.width/2)
        box.physicsBody?.dynamic = false
        addChild(box)
    }
    func addBouncers (position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width/2)
        bouncer.physicsBody?.contactTestBitMask = (bouncer.physicsBody?.collisionBitMask)!
        bouncer.physicsBody?.dynamic = false
        addChild(bouncer)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        //if either of them is a ball, remove it if the second part is a slot base
        if contact.bodyA.node!.name == "ball" {
            collisionBetweenBall(contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node!.name == "ball" {
            collisionBetweenBall(contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called/Users/a/Documents/learningSwift/HackingWithSwift/project11-files/Content when a touch begins */
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            
            let objects = nodesAtPoint(location) as [SKNode]
            if objects.contains(editLabel){
                editingMode = !editingMode
            }
            else {
                if editingMode {
                    createBumpers(location)
                }
                else{
                    let validY = CGFloat(650)
                    if location.y >  validY {
                        let ball = SKSpriteNode(imageNamed: "ballRed")
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
                        //contactTestBitMask ->what collision I want to know about
                        //collisionBitMask -> who should I bump into? Collide with everything(default)
                        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)! //<-Basically saying tell me about every collision
                        ball.physicsBody?.restitution = 0.4
                        ball.position = location
                        ball.name = "ball"
                        addChild(ball)
                    }
                }
            }

        }

    }
    func createBumpers (location: CGPoint){
        let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
        let box = SKSpriteNode(color: RandomColor(), size: size)
        box.zRotation = randomCGFloat(0, max:3)
        box.position = location
        
        box.physicsBody = SKPhysicsBody(rectangleOfSize: box.size)
        box.physicsBody?.dynamic = false
        addChild(box)
    }
    func collisionBetweenBall(ball: SKNode, object: SKNode) {
        //print("Collide")
        if object.name == "Good"{
            destroyBall(ball)
            ++score
        }
        else if object.name == "Bad"{
            destroyBall(ball)
            --score
        }
    }
    
    func destroyBall(ball:SKNode){
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
