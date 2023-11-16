//
//  BaseViewController.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setHierarchy()
        setConstraints()
    }
    
    func setHierarchy() {
        
    }
    
    func setConstraints() {
        view.backgroundColor = .white
    }
}
