//
//  DatePickerLabel.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/6.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit

class PickerLabel: UILabel {
    
    private let _inputView: UIView? = {
        let picker = UIDatePicker()
        return picker
    }()
    
    private let _inputAccessoryToolbar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        
        toolBar.sizeToFit()
        
        return toolBar
    }()
    
    override var inputView: UIView? {
        return _inputView
    }
    
    override var inputAccessoryView: UIView? {
        return _inputAccessoryToolbar
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem:.flexibleSpace, target: nil, action: nil)
        
        _inputAccessoryToolbar.setItems([ spaceButton, doneButton], animated: false)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(launchPicker))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc private func launchPicker() {
        becomeFirstResponder()
    }
    
    @objc private func doneClick() {
        resignFirstResponder()
    }

}
