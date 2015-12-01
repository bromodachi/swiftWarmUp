//
//  ViewController.swift
//  guessTheFlag
//
//  Created by a on 11/15/15.
//  Copyright © 2015 a. All rights reserved.
//

import UIKit
import GameplayKit //for making it more random

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    var countries = [String] ()
    var score = 0
    var correctAnswer = 0
  //  var title: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        //set border width
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        //set color
        //UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0).CGColor
        button1.layer.borderColor = UIColor.lightGrayColor().CGColor
        button2.layer.borderColor = UIColor.lightGrayColor().CGColor
        button3.layer.borderColor = UIColor.lightGrayColor().CGColor
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        askQuestion()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func askQuestion(action: UIAlertAction! = nil){
        countries = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(countries) as! [String]
        button1.setImage(UIImage(named: countries[0]), forState: .Normal)
        button2.setImage(UIImage(named: countries[1]), forState: .Normal)
        button3.setImage(UIImage(named: countries[2]), forState: .Normal)
        
        correctAnswer = GKRandomSource.sharedRandom().nextIntWithUpperBound(3)
        
        titleLabel.text = countries[correctAnswer].uppercaseString
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func answerQuestion(sender: UIButton) {
        var title:String
        if sender.tag == correctAnswer{
            titleLabel.text = "Correct"
            ++score
        }
        
        else {
            titleLabel.text = "Wrong"
            --score
        }
        
         let ac = UIAlertController(title: titleLabel.text, message: "Your score is \(score).", preferredStyle: .Alert)
        
        ac.addAction(UIAlertAction(title: "Continue", style: .Default, handler: askQuestion))
            presentViewController(ac, animated: true, completion: nil)
        
    }

}

