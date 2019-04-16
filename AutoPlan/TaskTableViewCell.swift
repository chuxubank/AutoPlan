//
//  TaskTableViewCell.swift
//  AutoPlan
//
//  Created by Misaka on 2019/4/3.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var noteLabel: UILabel!
    
    func update(with task: Task) {
        titleLabel.text = task.title
        noteLabel.text = task.notes
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
