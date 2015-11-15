//
//  MasterViewController.swift
//  world scramble
//
//  Created by a on 11/15/15.
//  Copyright © 2015 a. All rights reserved.
//

import UIKit
import GameplayKit

class MasterViewController: UITableViewController {
    
    //var detailViewController: DetailViewController? = nil
    var objects = [String]()
    var allWords = [String] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "getAnswer")
        //get the path of the file
        guard let startWordsPath = NSBundle.mainBundle().pathForResource("start", ofType: "txt")
            else {
                allWords = ["racecar"]
                return
        }
        //then actually load the file content into a string
        guard let startWords = try? String(contentsOfFile: startWordsPath, usedEncoding: nil)
            else {
                allWords = ["racecar"]
                return
        }
        //from the string, break it into entries
        allWords = startWords.componentsSeparatedByString("\n")
        
        startGame()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func getAnswer () {
        let alert = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .Alert)
         alert.addTextFieldWithConfigurationHandler(nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default){ [unowned self, alert] _ in
            let answer = alert.textFields![0]
            self.submitAnswer(answer.text!)
        }
        
        alert.addAction(submitAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func submitAnswer(answer: String){
        let lowerAnswer = answer.lowercaseString
        let errorTitle :String
        let errorMessage:String
        if wordIsPossible(lowerAnswer) && wordIsOriginal(lowerAnswer) && wordIsReal(lowerAnswer) {
            objects.insert(answer, atIndex: 0)
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            return
        }
        else {
            errorTitle = "Error"
            errorMessage = "Either the word you entered is already submitted,\n wasnt't original\n or real"
        }
        
        let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func wordIsPossible(word:String) -> Bool{
        
        var tempWord = title!.lowercaseString
        
        for letters in tempWord.characters {
            //for each letter in the tempword, find the letter in the word, remove it
            if let pos = tempWord.rangeOfString(String(letters)) {
                tempWord.removeAtIndex(pos.startIndex)
            }
            else {
                // no letter found
                return false
            }
        }
        return true
    }
    func wordIsOriginal(word:String) -> Bool{
        return !objects.contains(word)
    }
    
    func wordIsReal(word:String) -> Bool{
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let misspelledRange = checker.rangeOfMisspelledWordInString(word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func startGame () {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(allWords) as! [String]
        title = allWords[0]
        objects.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    
    
    
}

