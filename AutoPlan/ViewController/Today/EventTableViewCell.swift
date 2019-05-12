//
//  EventTableViewCell.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/11.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit
import EventKit

class EventTableViewCell: UITableViewCell {

    func update(with event: EKEvent) {
        let dateFormater = DateFormatter()
        dateFormater.timeStyle = .short
        imageView?.tintColor = UIColor(cgColor: event.calendar.cgColor)
        textLabel?.text = event.title
        detailTextLabel?.text = dateFormater.string(from: event.startDate)
        if event.endDate < Date() {
            textLabel?.textColor = UIColor.gray
            detailTextLabel?.textColor = UIColor.gray
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
