//
//  MasterViewController.swift
//  WhiteHousePetition
//
//  Created by reedex on 11/16/15.
//  Copyright © 2015 reedex. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [[String:String]]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString:String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString  = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            print("other string")
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
        let url = NSURL(string: urlString)
        guard let data = try? NSData(contentsOfURL: url!, options: [])
        else {
            //handle error
            print("failure")
            showError()

            return
        }
        let json = JSON(data: data)
        print(json["metadata"]["responseInfo"]["status"].intValue)
        if json["metadata"]["responseInfo"]["status"].intValue == 200 {
            //time to parse
            parseJSON(json)
        }
        else {
            showError()
        }
        //print("success")

    }
    
    func showError() {
        let alertController = UIAlertController(title: "Error", message: "Error loading content", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated:  true, completion: nil)
    }
    
    
    func parseJSON (json: JSON){
        for result in json["results"].arrayValue {
            //   print("success")
            let title = result["title"].stringValue
            let body = result["body"].stringValue
            let sigs = result["signatureCount"].stringValue
            let obj = ["title": title, "body": body, "sigs": sigs]
            objects.append(obj)
        }
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

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
        cell.textLabel!.text = object["title"]
        cell.detailTextLabel!.text = object["body"]
        return cell
    }


}

