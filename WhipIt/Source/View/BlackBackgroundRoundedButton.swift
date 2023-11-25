//
//  BlackBackgroundRoundedButton.swift
//  WhipIt
//
//  Created by Chaewon on 11/25/23.
//

import UIKit

final class BlackBackgroundRoundedButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = Font.bold16
        backgroundColor = .black
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 10
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
}
