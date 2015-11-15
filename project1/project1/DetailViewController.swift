//
//  DetailViewController.swift
//  project1
//
//  Created by a on 11/14/15.
//  Copyright © 2015 a. All rights reserved.
//

import UIKit
import Social


class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let imageView = self.detailImageView {
                imageView.image = UIImage(named: detail as! String)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "sharedTap")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    
    
    func sharedTap(){
        //let vc = UIActivityViewController(activityItems: [detailImageView.image!], applicationActivities: [])
        let alert = UIAlertController(title: "", message: "Where do you want to send it to?", preferredStyle: .ActionSheet)
        alert.addAction(getFacebook())
        alert.addAction(defaultShare())
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func defaultShare() -> UIAlertAction {
        return UIAlertAction(title: "Others...", style: .Default, handler: {
            (action) -> Void in
            let vc = UIActivityViewController(activityItems: [self.detailImageView.image!], applicationActivities: [])
            self.presentViewController(vc, animated: true, completion: nil)
        })
    }
    
    func getFacebook() -> UIAlertAction {
        return UIAlertAction(title: "Facebook", style: .Default, handler: {
            (action) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
                let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                vc.setInitialText("Look at this awesome NASA pic!")
                vc.addImage(self.detailImageView.image!)
                vc.addURL(NSURL(string: "http://www.photolib.noaa.gov/nssl"))
                self.presentViewController(vc, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Error", message: "Not logged into Facebook!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Error", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

