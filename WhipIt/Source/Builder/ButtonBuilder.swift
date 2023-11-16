//
//  ButtonBuilder.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import UIKit

extension UIButton {
    static func buttonBuilder(image: UIImage? = nil, title: String? = nil, font: UIFont? = nil) -> UIButton {
        let view = UIButton()
        view.titleLabel?.font = font
        view.setTitle(title, for: .normal)
        view.setImage(image, for: .normal)
        return view
    }
}
