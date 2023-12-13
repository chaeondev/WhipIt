//
//  HashTagButton.swift
//  WhipIt
//
//  Created by Chaewon on 12/12/23.
//

import UIKit

final class HashTagButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        configureCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        self.titleLabel?.font = UIFont(name: Suit.semiBold, size: 12)!
        self.setTitleColor(.black, for: .normal)
        
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray4.cgColor
        
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}
