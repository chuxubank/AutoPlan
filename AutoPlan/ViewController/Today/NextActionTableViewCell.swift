//
//  NextActionTableViewCell.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/12.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit

class NextActionTableViewCell: UITableViewCell {
    
    var task: Task? = nil
    
    func update(with nextAction: Task, unitCount: Int) {
        textLabel?.text = nextAction.title! + String(format: " %d %@", unitCount, nextAction.splitUnit!)
        detailTextLabel?.text = String(format: "Energy: %d", Int(nextAction.energyLevel))
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
