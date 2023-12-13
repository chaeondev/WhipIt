//
//  CommentTextField.swift
//  WhipIt
//
//  Created by Chaewon on 12/12/23.
//

import UIKit

final class CommentTextField: UITextField {
    
    lazy var registerButton = UIButton.buttonBuilder(title: "등록", font: Font.bold14, titleColor: .black)
    lazy var paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.frame.height))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.placeholder = "댓글을 남기세요..."
        self.font = UIFont(name: Suit.light, size: 14)
        self.borderStyle = .none
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.textColor = .black
        self.backgroundColor = .systemGray6
        self.leftViewMode = .always
        self.leftView = paddingView
        self.rightViewMode = .whileEditing
        self.rightView = registerButton
        self.keyboardType = .twitter
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 50, y: 8, width: bounds.height, height: bounds.height-15)
    }
    
}

