//
//  BookmarkButton.swift
//  WhipIt
//
//  Created by Chaewon on 12/13/23.
//

import UIKit

final class BookmarkButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureButton() {
        backgroundColor = .clear
        setImage(UIImage(resource: .ribbon), for: .normal)
        tintColor = .gray
        
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.setImage(UIImage(resource: .ribbonFill), for: .normal)
            } else {
                self.setImage(UIImage(resource: .ribbon), for: .normal)
            }
        }
    }
    
    
}
