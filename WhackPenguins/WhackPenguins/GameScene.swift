//
//  GameScene.swift
//  WhackPenguins
//
//  Created by a on 12/13/15.
//  Copyright (c) 2015 bromodachi. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene {
    
    var gameScore :SKLabelNode!
    var slots = [WhackSlot] ()
    var round = 0
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    var popupTime = 0.85 //make it easy at first, decrease it later
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 383)
        background.blendMode = .Replace
        background.zPosition = -1
        addChild(background)
        
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 700)
        gameScore.horizontalAlignmentMode = .Left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        createSlots()
        runDelay(1){
            [unowned self] in
            self.createEnemy()
        }
        
    }
    
    func createEnemy () {
        
        round++
        if round >= 30{
            for slot in slots {
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x:512, y:384)
            gameOver.zPosition = 1
            addChild(gameOver)
            return
        }
        popupTime *= 0.991
        
        slots = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(slots) as! [WhackSlot]
        slots[0].show(hideTime: popupTime)
        
        if randomInt(0, max: 12) > 4 {
            slots[1].show(hideTime: popupTime)
        }
        if randomInt(0, max: 12) > 8 {
            slots[2].show(hideTime: popupTime)
        }
        if randomInt(0, max: 12) > 10 {
            slots[3].show(hideTime: popupTime)
        }
        if randomInt(0, max: 12) > 11 {
            slots[4].show(hideTime: popupTime)
        }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        
        runDelay(randomDouble(minDelay, max: maxDelay)){
            [unowned self] in
            self.createEnemy()
        }
    }
    
    func createSlots() {
        for i in 0..<5 {
            createSlotAt(CGPoint(x:100 + (i*170), y:410) )
            createSlotAt(CGPoint(x: 100 + (i*170), y:230))
            if(i < 4){
                createSlotAt(CGPoint(x: 180 + (i*170), y:320))
                createSlotAt(CGPoint(x: 180 + (i*170), y:140))
            }
        }
    }
    
    func createSlotAt(pos: CGPoint) {
        let slot = WhackSlot()
        slot.configureAtPosition(pos)
        addChild(slot)
        slots.append(slot)
    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            let nodes = nodesAtPoint(location)
            
            for node in nodes {
                if node.name == "charFriend" {
                    //decrease points
                    let whackSlot = node.parent!.parent as! WhackSlot
                    //the user tops the sprite node, not the slot node
                    //get the parent of the sprite, which is the crop node
                    //the crop node parent is the WhackSlot
                    if !whackSlot.visible || whackSlot.isHit {
                        continue
                    }
                    
                    whackSlot.hit()
                    score -= 5
                    
                    runAction(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
                
                }
                else if node.name == "charEvil"{
                    //increase points
                    let whackSlot = node.parent!.parent as! WhackSlot
                    //the user tops the sprite node, not the slot node
                    //get the parent of the sprite, which is the crop node
                    //the crop node parent is the WhackSlot
                    if !whackSlot.visible || whackSlot.isHit {
                        continue
                    }
                    whackSlot.charNode.xScale = 0.85
                    whackSlot.charNode.yScale = 0.85
                    whackSlot.hit()
                    score += 1
                    
                    runAction(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
