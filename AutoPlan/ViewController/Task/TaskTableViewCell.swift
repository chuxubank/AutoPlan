//
//  TaskTableViewCell.swift
//  AutoPlan
//
//  Created by Misaka on 2019/4/3.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit

@objc protocol TaskCellDelegate: class {
    func checkMarkTapped(sender: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell {
    
    var delegate: TaskCellDelegate?
    
    @IBOutlet weak var doneProgressView: UIProgressView!
    
    @objc func imageViewTapped() {
        delegate?.checkMarkTapped(sender: self)
    }
    
    func update(with task: Task) {
        let color = task.project?.color as? UIColor
        textLabel?.text = task.title
        textLabel?.textColor = task.isDone ? UIColor.gray : UIColor.black
        imageView?.image = task.isDone ? UIImage(named: "dot circle") : UIImage(named: "circle")
        imageView?.tintColor = color
        doneProgressView.isHidden = task.splitCount == 1
        doneProgressView.progressTintColor = color
        doneProgressView.trackTintColor = color?.withAlphaComponent(0.1)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let leadingConstraint = NSLayoutConstraint.init(item: doneProgressView!, attribute: .leading, relatedBy: .equal, toItem: textLabel, attribute: .leading, multiplier: 1.0, constant: 0)
        self.addConstraints([leadingConstraint])
        imageView?.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        gesture.numberOfTapsRequired = 1
        imageView?.addGestureRecognizer(gesture)
    }
}
