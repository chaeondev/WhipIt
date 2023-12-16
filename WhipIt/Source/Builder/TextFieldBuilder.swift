//
//  TextFieldBuilder.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import UIKit

extension UITextField {
    static func underlineTextFieldBuilder(placeholder: String, textColor: UIColor, textAlignment: NSTextAlignment = .center, font: UIFont = Font.light14) -> UnderlineTextField {
        let view = UnderlineTextField()
        view.setPlaceholder(placeholder: placeholder)
        view.font = font
        view.textColor = textColor
        view.textAlignment = textAlignment
        return view
    }
    
    static func textFieldBuilder(placeholder: String, textColor: UIColor, font: UIFont = Font.light14) -> UITextField {
        let view = UITextField()
        view.placeholder = placeholder
        view.textColor = textColor
        view.font = font
        view.borderStyle = .none
        return view
    }
}
