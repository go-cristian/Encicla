//
//  StationViewCell.swift
//  encilcla
//
//  Created by Cristian Gomez on 21/12/16.
//  Copyright © 2016 Iyubinest. All rights reserved.
//

import UIKit

class StationViewCell: UITableViewCell {

    static let REHUSE_NAME = "StationViewCell"
    
    @IBOutlet var nameView: UILabel!
    @IBOutlet var bikesView: UILabel!
    
    var station:BikeResponseItem? {
        didSet {
            nameView.text = station?.name
            if let bikes = station?.bikes{bikesView.text = String(describing: bikes)}
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
