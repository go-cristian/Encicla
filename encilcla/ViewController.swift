//
//  ViewController.swift
//  encilcla
//
//  Created by Cristian Gomez on 18/12/16.
//  Copyright © 2016 Iyubinest. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet var bikeTableView: UITableView!
    
    var bikeResults:[Station]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func findBikeAction(_ sender: AnyObject) {
        
    }
    
    func tableView(_ tableView: UITableView,
                     numberOfRowsInSection section: Int) -> Int {
        return bikeResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath)
    }
    
}

struct Station{
    var name:String?
    var capacity:Int?
    var current:Int?
}

