//
//  EventTableViewCell.swift
//  Calendar
//
//  Created by Max Reuter on 20/11/15.
//  Copyright © 2015 reuterm. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
