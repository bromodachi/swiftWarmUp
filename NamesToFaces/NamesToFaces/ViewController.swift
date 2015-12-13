//
//  ViewController.swift
//  NamesToFaces
//
//  Created by a on 11/30/15.
//  Copyright © 2015 bromodachi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //UICollection needs this:
    //how many items of data it should expect and what each item should contain.
    var people = [Person]()
    
    var indexGlobal:NSIndexPath!

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewPerson")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedPeople = defaults.objectForKey("people") as? NSData {
            people = NSKeyedUnarchiver.unarchiveObjectWithData(savedPeople) as! [Person]
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Person", forIndexPath: indexPath) as! PersonCell
        
        let person = people [indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().stringByAppendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path)
        
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        indexGlobal = indexPath
        let alert = UIAlertController(title: "", message: "What do you want to do?", preferredStyle: .ActionSheet)
        
        alert.addAction(changeImage())
        alert.addAction(renamePersonAlert())
        alert.addAction(deleteImage())
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (action) -> Void in
                self.indexGlobal = nil
        }))
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
    func deleteImage() ->UIAlertAction {
        return UIAlertAction(title: "Delete", style: .Default, handler: {
            (action) -> Void in
            self.deletePerson()
        })
    }
    func renamePersonAlert () ->UIAlertAction {
        return UIAlertAction(title: "Change Name", style: .Default, handler: {
            (action) -> Void in
            self.renamePerson()
        })

    }
    
    func deletePerson () {
        people.removeAtIndex(indexGlobal.item)
        indexGlobal = nil
        self.save()
        self.collectionView.reloadData()
    }
    
    
    func changeImage() -> UIAlertAction{
        return UIAlertAction(title: "Change Image", style: .Default, handler: {
            (action) -> Void in
            self.addNewPerson();
        })
        
    }
    
    func renamePerson (){
        let person = people[indexGlobal.item]
        
        let alertController = UIAlertController(title: "Rename", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "OK", style: .Default){ [unowned self] _ in
            let newName = alertController.textFields![0]
            person.name = newName.text!
            
            
            self.save()
            self.collectionView.reloadData()
            
            })
        indexGlobal = nil
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func addNewPerson(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    //if the users hits cancel
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
            
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        }
        else {
            return
        }
        //create a random file name
        let imageName = NSUUID().UUIDString
        //get the path where to save the image in the directory
        let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
        
        //convert to JPEG image and write to the path we created before. example ../Documents/RandomName.jpeg
        if let jpegData = UIImageJPEGRepresentation(newImage, 80){
            jpegData.writeToFile(imagePath,atomically : true)//"write to a temporary file first, then rename it to be the file we asked,"
        }
        
        if(indexGlobal != nil){
            people[indexGlobal.item].image = imageName
            indexGlobal = nil
        }
        else{
            let person = Person(name: "Unknown", image: imageName)
            people.append(person)
        }
        collectionView.reloadData()
        
        
        dismissViewControllerAnimated(true, completion: nil)
        save()
        
    }
    func getDocumentsDirectory() -> NSString {
        //second parameter adds that we want the path to be relative to the user's home directory.
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0] //returns the user's documents directory
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func save () {
        let savedData = NSKeyedArchiver.archivedDataWithRootObject(people)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(savedData, forKey: "people")
    }


}

