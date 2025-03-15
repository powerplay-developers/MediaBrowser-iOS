//
//  PaddedTextField.swift
//  MediaBrowser
//
//  Created by Adarsh   on 13/03/25.
//

import UIKit

class PaddedTextField: UITextField {
    
    private lazy var insets: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    
    init(insets: UIEdgeInsets? = nil) {
        super.init(frame: .zero)
        self.insets = insets ?? .init(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    private func setInsets(forBounds bounds: CGRect) -> CGRect {
        var totalInsets = insets
        if let leftView = leftView  {
            let leftViewWidth = leftView.runtimeSize().width
            totalInsets.left += leftView.frame.origin.x + leftViewWidth
        }
        if let rightView = rightView {
            let rightViewWidth = rightView.runtimeSize().width
            totalInsets.right += rightView.bounds.size.width + rightViewWidth
        }
        return bounds.inset(by: totalInsets)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return setInsets(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return setInsets(forBounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return setInsets(forBounds: bounds)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= insets.right
        return rect
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += insets.left
        return rect
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addDoneButtonOnKeyboard()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

