//
//  UITextField+Extension.swift
//  MediaBrowser
//
//  Created by Adarsh   on 13/03/25.
//

import UIKit

extension UITextField {
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }
    
    @objc fileprivate func doneButtonAction() {
        self.resignFirstResponder()
    }
    
    func getResultedText(range: NSRange, replacementText: String) -> String{
        
        guard let _text = self.text else { return replacementText }
        
        if let textRange = Range(range, in: _text){
            return _text.replacingCharacters(in: textRange, with: replacementText)
        }
        return replacementText
    }
}
