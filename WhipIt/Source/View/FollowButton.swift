//
//  FollowButton.swift
//  WhipIt
//
//  Created by Chaewon on 12/19/23.
//

import UIKit

final class FollowButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureButton() {
        setTitle("팔로우", for: .normal)
        titleLabel?.font = UIFont(name: Suit.semiBold, size: 12)!
        backgroundColor = .black
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 10
        
    }
    
    override var isSelected: Bool  {
        didSet {
            if isSelected {
                self.setTitle("팔로잉", for: .normal)
                self.backgroundColor = .white
                self.setTitleColor(.black, for: .normal)
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor.lightGray.cgColor
                
            } else {
                self.setTitle("팔로우", for: .normal)
                self.backgroundColor = .black
                self.setTitleColor(.white, for: .normal)
                self.layer.borderColor = UIColor.black.cgColor

            }
        }
    }
   
}
