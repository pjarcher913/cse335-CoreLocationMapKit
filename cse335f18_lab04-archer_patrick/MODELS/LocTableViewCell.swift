//
//  LocTableViewCell.swift
//  cse335f18_lab04-archer_patrick
//
//  Created by Patrick Archer on 9/27/18.
//  Copyright © 2018 Patrick Archer - Self. All rights reserved.
//

import Foundation
import UIKit

class LocTableViewCell: UITableViewCell {
    
    @IBOutlet weak var locDescription: UILabel!
    @IBOutlet weak var locTitle: UILabel!
    @IBOutlet weak var locImage: UIImageView!{
        didSet {
            locImage.layer.cornerRadius = locImage.bounds.width / 2
            locImage.clipsToBounds = true
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
