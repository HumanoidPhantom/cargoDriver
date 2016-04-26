//
//  MenuTableViewController.swift
//  WhereMyChild
//
//  Created by Phantom on 27/03/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    static let storyboardID = "MenuViewController"
    let myRootRef = Firebase(url:"https://torrid-torch-3622.firebaseio.com")
    
    @IBAction func exitButton(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let _ = defaults.objectForKey("user") as? [String:String] {
            myRootRef.unauth()
            defaults.removeObjectForKey("user")
            showEnterViewAnimated(true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return 2
    //    }
    
    func showEnterViewAnimated(animated: Bool) {
        self.navigationController?.popToRootViewControllerAnimated(animated)
    }
    
}
