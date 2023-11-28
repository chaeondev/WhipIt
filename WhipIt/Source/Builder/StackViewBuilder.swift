//
//  StackViewBuilder.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import UIKit

extension UIStackView {
    static func stackViewBuilder(axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, spacing: CGFloat, alignment: UIStackView.Alignment = .center) -> UIStackView {
        let view = UIStackView()
        view.axis = axis
        view.distribution = distribution
        view.alignment = alignment
        view.spacing = spacing
        return view
    }
}
