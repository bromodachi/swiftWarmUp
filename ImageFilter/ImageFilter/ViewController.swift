//
//  ViewController.swift
//  ImageFilter
//
//  Created by a on 12/12/15.
//  Copyright © 2015 bromodachi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intesity: UISlider!
    
    var currentImage: UIImage! //original image
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = CIContext(options: nil)
        currentFilter = CIFilter(name: "CISepiaTone")
        
        title = "Image Filter"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "importImage")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func importImage () {
        let imagePicker = UIImagePickerController ()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
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
        
      //  let imageName = NSUUID().UUIDString
        //get the path where to save the image in the directory
        
        
        dismissViewControllerAnimated(true, completion: nil)
        currentImage = newImage
        
        let beginImage = CIImage(image: currentImage)
        //print(beginImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
        
    }
    

    @IBAction func changeFilter(sender: AnyObject) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func setFilter(action:UIAlertAction) {
        currentFilter = CIFilter(name: action.title!)
        
        let beginImage = CIImage(image: currentImage)
        
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
        
        
    }
    
    
    @IBAction func intensityChanged(sender: AnyObject) {
        applyProcessing()
    }
    
    func applyProcessing(){
        
  
        if currentFilter.inputKeys.contains(kCIInputIntensityKey){
            currentFilter.setValue(intesity.value, forKey: kCIInputIntensityKey)
        }
        if (currentFilter.inputKeys.contains(kCIInputRadiusKey)){
            currentFilter.setValue(intesity.value*150, forKey: kCIInputRadiusKey)
        }
        if (currentFilter.inputKeys.contains(kCIInputScaleKey)){
            currentFilter.setValue(intesity.value*10, forKey: kCIInputScaleKey)
        }
        if (currentFilter.inputKeys.contains(kCIInputCenterKey)){
            currentFilter.setValue(CIVector(x: (currentImage.size
                .width)/2, y: (currentImage.size
                    .height)/2), forKey: kCIInputCenterKey)
        }
        
        let cgImage = context.createCGImage(currentFilter.outputImage!, fromRect: (currentFilter.outputImage?.extent)!)
        let processedImage = UIImage(CGImage: cgImage)
        
        imageView.image = processedImage
    }

    @IBAction func save(sender: AnyObject) {
        if(imageView.image != nil){
            UIImageWriteToSavedPhotosAlbum(imageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Completed", message: "Image was saved", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        
        } else {
            let ac = UIAlertController(title: "", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

