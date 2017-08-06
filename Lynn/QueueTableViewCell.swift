//
//  QueueTableViewCell.swift
//  Lynn
//
//  Created by Alexander Li on 7/21/17.
//  Copyright © 2017 Alexander Li. All rights reserved.
//

import UIKit

class QueueTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
