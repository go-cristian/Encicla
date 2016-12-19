//
//  ViewController.swift
//  encilcla
//
//  Created by Cristian Gomez on 18/12/16.
//  Copyright © 2016 Iyubinest. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet var bikeTableView: UITableView!
    
    var bikeResults:[Station]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func findBikeAction(sender: AnyObject) {
    }
    
    func tableView(tableView: UITableView,
                     numberOfRowsInSection section: Int) -> Int {
        return bikeResults?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("StationCell", forIndexPath: indexPath)
    }
    
}

struct Station{
    var name:String?
    var capacity:Int?
    var current:Int?
}

