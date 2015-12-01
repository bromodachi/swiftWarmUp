//
//  ViewController.swift
//  swiftWords
//
//  Created by a on 11/28/15.
//  Copyright © 2015 bromodachi. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {

    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var letterButtons = [UIButton] ()
    var activatedButtons = [UIButton] ()
    var solutions = [String] ()
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)" //automatically changes when the score value gets changed
        }
    }
    var level = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for subview in view.subviews where subview.tag == 1001{
            let button = subview as! UIButton
            letterButtons.append(button)
            // : means it takes one parameter
            button.addTarget(self, action: "letterTapped:", forControlEvents: .TouchUpInside)
        }
        
        loadLevel()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func submitTapped(sender: AnyObject) {
        
        if let solutionPosition = solutions.indexOf(currentAnswer.text!){
            activatedButtons.removeAll()
            
            var splitsClues = answersLabel.text?.componentsSeparatedByString("\n")
            splitsClues![solutionPosition] = currentAnswer.text!
            answersLabel.text = splitsClues!.joinWithSeparator("\n")
            
            currentAnswer.text = ""
            
            ++score
            
            if score % 7 == 0 && score != 0 {
                let alertController = UIAlertController(title: "Level one complete~", message: "Ready?", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Ready!", style: .Default, handler: levelUp))
                presentViewController(alertController, animated: true, completion: nil)
            }
        }
        else {
            --score
        }
    }
    
    func levelUp(action: UIAlertAction!) {
        ++level
        solutions.removeAll(keepCapacity: true)
        
        loadLevel()
        
        for btn in letterButtons {
            btn.hidden = false
        }
    }
    @IBAction func clearTapped(sender: AnyObject) {
        
        currentAnswer.text = ""
        for button in activatedButtons {
            button.hidden = false
        }
        activatedButtons.removeAll()
    }

    @IBOutlet weak var clearTapped: UIButton!
    
    func loadLevel(){
        var clueString = ""
        var solutionString = ""
        
        var letterBits = [String] ()
        
        if let levelFilePath = NSBundle.mainBundle().pathForResource("level\(level)", ofType: "txt"){
            if let levelContents = try? String(contentsOfFile: levelFilePath){
                var lines = levelContents.componentsSeparatedByString("\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(lines) as! [String]
                
                for(index, line) in lines .enumerate(){
                    let parts = line.componentsSeparatedByString(": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index+1). \(clue)\n"
                    
                    let solutionWord = answer.stringByReplacingOccurrencesOfString("|", withString: "")
                    solutionString += "\(solutionWord.characters.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits  = answer.componentsSeparatedByString("|")
                    letterBits += bits
                }
                
            }
        }
        
        cluesLabel.text = clueString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        answersLabel.text = solutionString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterBits) as! [String]
        letterButtons = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterButtons) as! [UIButton]
        
        if letterBits.count == letterButtons.count {
            for i in 0 ..< letterBits.count {
                letterButtons[i].setTitle(letterBits[i], forState: .Normal)
            }
        }
    }
    
    func letterTapped(button:UIButton) {
        currentAnswer.text = currentAnswer.text! + (button.titleLabel?.text)!
        activatedButtons.append(button)
        button.hidden = true
    }

}

