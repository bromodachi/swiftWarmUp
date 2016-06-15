//
//  GameScene.swift
//  FruitNinjaClone
//
//  Created by a on 12/12/15.
//  Copyright (c) 2015 bromodachi. All rights reserved.
//

import SpriteKit

import AVFoundation

enum SequenceType: Int {
    case OneNoBomb, One, TwoWithOneBomb, Two, Three, Four, Chain, FastChain
}
enum ForceBomb {
    case Never, Always, Default
}
class GameScene: SKScene {
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var scoreLabel: SKLabelNode!
    var bombSoundEffect: AVAudioPlayer!
    var gameEnded = false
    
    var activeSlicePoints = [CGPoint] ()
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var activeEnemies = [SKSpriteNode] ()
    
    var popupTime = 0.9
    var sequence: [SequenceType]! //array of our enemu that defines what enemies to createe
    var sequencePosition = 0 //current pointin the game
    var chainDelay = 3.0 //how long to go either normal or fast chain
    var nextSequenceQueued = true //if all enemies are destroyed, make new ones aka the penguins
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6) //tell the physics to adjust downwards
        physicsWorld.speed = 0.85 //make the items stay up longer
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.OneNoBomb, .OneNoBomb, .TwoWithOneBomb, .TwoWithOneBomb, .Three, .One, .Chain]
        for _ in 0 ... 1000{
            let nextSequence = SequenceType(rawValue: randomInt(2, max: 7))
            sequence.append(nextSequence!)
        }
        
        runDelay(2, block: {
            [unowned self] in
            self.tossEnemies()
        })
    }
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.fontSize = 48
        
        addChild(scoreLabel)
        
        scoreLabel.position = CGPoint(x:8,y:8)
        
        
    }
    
    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x:CGFloat(834 + (i * 70)) , y:720)
            addChild(spriteNode)
            
            livesImages.append(spriteNode)
        }
    }
    
    func createSlices () {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 2
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.whiteColor()
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameEnded {
            return
        }
        guard let touch = touches.first
            else{
                return
            }
        
        let location = touch.locationInNode(self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        let nodes = nodesAtPoint(location)
        
        for node in nodes {
            if node.name == "enemy" {
                let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy.sks")!
                emitter.position = node.position
                addChild(emitter)
                
                node.name = ""
                
                node.physicsBody?.dynamic = false
                
                let scaleOut = SKAction.scaleTo(0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOutWithDuration(0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                
                node.runAction(seq)
                
                ++score
                
                let index = activeEnemies.indexOf(node as! SKSpriteNode)
                
                activeEnemies.removeAtIndex(index!)
                
                runAction(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            
            } else if node.name == "bomb" {
                let emitter = SKEmitterNode(fileNamed: "sliceHitBomb.sks")!
                emitter.position = node.position
                addChild(emitter)
                
                node.name = ""
                
                node.physicsBody?.dynamic = false
                
                let scaleOut = SKAction.scaleTo(0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOutWithDuration(0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                
                node.parent!.runAction(seq)
                
                
                
                let index = activeEnemies.indexOf(node.parent as! SKSpriteNode)!
                
                activeEnemies.removeAtIndex(index)
                
                runAction(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        activeSlicePoints.removeAll(keepCapacity: true)
        
        if let touch = touches.first{
            let location = touch.locationInNode(self)
            activeSlicePoints.append(location)
            redrawActiveSlice()
            
            activeSliceBG.removeAllActions()
            activeSliceFG.removeAllActions()
            
            activeSliceFG.alpha = 1
            activeSliceBG.alpha = 1
        }
        
    }
    
    func redrawActiveSlice(){
        if(activeSlicePoints.count < 2){
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        while (activeSlicePoints.count > 20){
            activeSlicePoints.removeFirst()
        }
        let path = UIBezierPath()
        path.moveToPoint(activeSlicePoints[0])
        
        for var i = 1; i < activeSlicePoints.count ; i++ {
            path.addLineToPoint(activeSlicePoints[i])
        }
        activeSliceBG.path = path.CGPath
        activeSliceFG.path = path.CGPath
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        activeSliceBG.runAction(SKAction.fadeOutWithDuration(0.25))
        activeSliceFG.runAction(SKAction.fadeOutWithDuration(0.25))
    }
    
    func createEnemy(ForceBomb forceBomb: ForceBomb = .Default){
        var enemy: SKSpriteNode
        
        var enemyType = randomInt(0, max: 6)
        
        if forceBomb == .Never {
            enemyType = 1 //we want the playet to slice this
        }
        else if forceBomb == .Always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            //make it a bomb
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil{
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
            let path = NSBundle.mainBundle().pathForResource("sliceBombFuse.caf", ofType:nil)!
            let url = NSURL(fileURLWithPath: path)
            let sound = try! AVAudioPlayer(contentsOfURL: url)
            bombSoundEffect = sound
            sound.play()
            
            let emitter = SKEmitterNode(fileNamed:"sliceFuse.sks")!
            emitter.position = CGPoint(x:76, y:64)
            enemy.addChild(emitter)
        }
        
        else {
            //make it a penguin
            enemy = SKSpriteNode(imageNamed: "penguin")
            runAction(SKAction.playSoundFileNamed("launch.caf", waitForCompletion : false))
            enemy.name = "enemy"
        }
        
        
        let randomPosition = CGPoint(x: randomInt(64, max: 940), y: -128)
        enemy.position = randomPosition
        
        let angularVelocity = CGFloat(randomInt(-6, max: 6))/2.0
        var xVelocity = 0
        if randomPosition.x < 256 {
            xVelocity = randomInt(8, max: 15)
        }
        else if randomPosition.x < 512 {
            xVelocity = randomInt(3, max: 5)
        }
        
        else if randomPosition.x < 768 {
            xVelocity = -randomInt(3, max: 5)
        }
        else {
            xVelocity = -randomInt(8, max: 15)
        }
        
        let yVelocity = randomInt(24, max: 32)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: xVelocity * 40 , dy: yVelocity * 40)
        enemy.physicsBody?.angularVelocity = angularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func tossEnemies (){
        if gameEnded {
            return
        }
        popupTime *= 0.991 //increase enemies toss up speed bit by bit
        chainDelay *= 0.99 //increase the chain delay.
        physicsWorld.speed *= 1.02 //increase the time to toss the penguin and how fast they drop
        
        let sequenceType = sequence[sequencePosition]
        switch sequenceType{
        case .OneNoBomb:
            createEnemy(ForceBomb: .Never)
        case .One:
            createEnemy()
        case .TwoWithOneBomb:
            createEnemy(ForceBomb: .Never)
        case .Two:
            createEnemyXTimes(2)
        case .Three:
            createEnemyXTimes(3)
        case .Four:
            createEnemyXTimes(4)
        case .Chain:
            createEnemy()
            
            runDelay(chainDelay / 5.0 ){[unowned self] in self.createEnemy()}
            runDelay(chainDelay / 5.0 * 2){[unowned self] in self.createEnemy()}
            runDelay(chainDelay / 5.0 * 3){[unowned self] in self.createEnemy()}
            runDelay(chainDelay / 5.0 * 4){[unowned self] in self.createEnemy()}
            
        case .FastChain:
            createEnemy()
            
            runDelay(chainDelay / 10.0 ){[unowned self] in self.createEnemy()}
            runDelay(chainDelay / 10.0 * 2){[unowned self] in self.createEnemy()}
            runDelay(chainDelay / 10.0 * 3){[unowned self] in self.createEnemy()}
            runDelay(chainDelay / 10.0 * 4){[unowned self] in self.createEnemy()}
        }
        
        ++sequencePosition
        
        nextSequenceQueued = false
    }
    
    func createEnemyXTimes(loop: Int){
        var counter = 0
        while(counter<loop){
            createEnemy()
            ++counter
        }
    }

    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if let touches = touches {
            touchesEnded(touches, withEvent: event)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                ++bombCount
                break
            }
        }
        
        if bombCount == 0 {
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
        }
        
        if activeEnemies.count > 0 {
            for node in activeEnemies {
                if node.position.y < -140 {
                    
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()
                        
                        node.removeFromParent()
                        
                        if let index = activeEnemies.indexOf(node) {
                            activeEnemies.removeAtIndex(index)
                        }
                        
                    }
                    else if node.name == "bombContainer" {
                    
                    node.name = ""
                        node.removeFromParent()
                        if let index = activeEnemies.indexOf(node) {
                            activeEnemies.removeAtIndex(index)
                        }
                    }
                }
            }
        }
        
        else {
        
            if !nextSequenceQueued{
                runDelay(popupTime, block: {
                    self.tossEnemies()
                })
                
                nextSequenceQueued = true
            }
            
            
        }
        
    }
    
    func subtractLife(){
        --lives
        //SKAction.playSoundFileName("wrong.caf")
        runAction(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        }
        else if lives == 1 {
            life = livesImages[1]
        }
        else {
            life = livesImages[2]
            endGame(triggeredByBomb:false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        life.runAction(SKAction.scaleTo(1, duration:0.1))
    }
    
    func endGame(triggeredByBomb triggeredByBomb: Bool) {
        if gameEnded {
            return
        }
        
        gameEnded = true
        physicsWorld.speed = 0
        userInteractionEnabled = false
        
        if bombSoundEffect != nil {
            bombSoundEffect.stop()
            bombSoundEffect = nil
        }
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
    }
}
