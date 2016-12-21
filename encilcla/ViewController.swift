//
//  ViewController.swift
//  encilcla
//
//  Created by Cristian Gomez on 18/12/16.
//  Copyright © 2016 Iyubinest. All rights reserved.
//

import UIKit
import ObjectMapper
import AlamofireObjectMapper
import Alamofire

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet var bikeTableView: UITableView!
    
    var bikeResults:[BikeResponseItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bikeResults = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func findBikeAction(_ sender: AnyObject) {
        let URL = "http://www.encicla.gov.co/status/"
        Alamofire.request(URL).responseObject{
                (response: DataResponse<BikeServerResponse>) in
            response.result.value.map{
                $0.stations!.map{
                    $0.items!.map{
                        self.bikeResults?.append($0)
                    }
                }
            }
            self.bikeTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView,
                     numberOfRowsInSection section: Int) -> Int {
        return bikeResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: StationViewCell.REHUSE_NAME, for: indexPath) as! StationViewCell
        cell.station = bikeResults?[indexPath.row]
        return cell
    }
    
}

struct Station{
    var name:String?
    var capacity:Int?
    var current:Int?
}

class BikeServerResponse: Mappable{
    var stations :[BikeResponseStation]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        stations <- map["stations"]
    }
}

class BikeResponseStation:Mappable{
    var items: [BikeResponseItem]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        items <- map["items"]
    }
}

class BikeResponseItem:Mappable{
    var lat: String?
    var lon: String?
    var name: String?
    var capacity: Int?
    var bikes: Int?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        lat <- map["lat"]
        lon <- map["lon"]
        name <- map["name"]
        capacity <- map["capacity"]
        bikes <- map["bikes"]
    }
}


