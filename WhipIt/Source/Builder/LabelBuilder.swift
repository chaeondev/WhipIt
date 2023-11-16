//
//  LabelBuilder.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import UIKit

extension UILabel {
    static func labelBuilder(text: String, font: UIFont, textColor: UIColor, numberOfLines: Int = 0, textAlignment: NSTextAlignment = .natural) -> UILabel {
        let view = UILabel()
        view.text = text
        view.font = font
        view.textColor = textColor
        view.numberOfLines = numberOfLines
        view.textAlignment = textAlignment
        return view
    }
}
