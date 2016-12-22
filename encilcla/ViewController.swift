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
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet var bikeTableView: UITableView!
    
    var bikeResults:[BikeResponseItem] = []
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: Array <CLLocation>) {
        getBikes(current: locations[0])
    }
    
    func getBikes(current: CLLocation){
        let currentMock = CLLocation(latitude: 6.220838, longitude: -75.573519)
        let URL = "http://www.encicla.gov.co/status/"
        Alamofire.request(URL).responseObject{
            (response: DataResponse<BikeServerResponse>) in
            self.bikeResults = (response.result.value?.stations!
                .flatMap{$0.items!.flatMap{$0}})!
                .sorted{
                    self.distance(bikeItem: $0, location: current) <
                    self.distance(bikeItem: $1, location: current)}
                .filter{$0.bikes!>0}
            self.bikeTableView.reloadData()
        }
    }
    
    func distance(bikeItem: BikeResponseItem, location: CLLocation) -> Double {
        let bikeDistance = CLLocation(
            latitude: Double(bikeItem.lat!)!,
            longitude: Double(bikeItem.lon!)!)
        return bikeDistance.distance(from: location)
    }
    
    func tableView(_ tableView: UITableView,
                     numberOfRowsInSection section: Int) -> Int {
        return bikeResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: StationViewCell.REHUSE_NAME, for: indexPath) as! StationViewCell
        cell.station = bikeResults[indexPath.row]
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


