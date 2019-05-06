//
//  ProjectTableViewCell.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/3.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {

    @IBOutlet weak var doneProgressView: UIProgressView!
    
    func update(with project: Project) {
        textLabel?.text = project.title
        let color = project.color as? UIColor
        doneProgressView.progressTintColor = color
        doneProgressView.trackTintColor = color?.withAlphaComponent(0.1)
    }
}
