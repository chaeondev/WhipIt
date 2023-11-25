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
    
    func showAlertMessage(title: String, message: String? = nil, handler: (() -> ())? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "확인", style: .default) { _ in
            handler?()
        }
        
//        alert.addAction(cancel)
        alert.addAction(ok)
        
        present(alert, animated: true)
        
    }
}
