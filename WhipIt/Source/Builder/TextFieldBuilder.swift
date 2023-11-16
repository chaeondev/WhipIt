//
//  TextFieldBuilder.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import UIKit

extension UITextField {
    static func underlineTextFieldBuilder(placeholder: String, textColor: UIColor, textAlignment: NSTextAlignment = .center) -> UnderlineTextField {
        let view = UnderlineTextField()
        view.setPlaceholder(placeholder: placeholder)
        view.textColor = textColor
        view.textAlignment = textAlignment
        return view
    }
}
