//
//  CircleView.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/3.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit

@IBDesignable
class UICircleView: UIView {

    @IBInspectable
    var color: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: 4.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        color.setFill()
        path.fill()
    }
}
