//
//  StyleDetailViewController.swift
//  WhipIt
//
//  Created by Chaewon on 12/6/23.
//

import UIKit
import RxSwift
import RxCocoa

class StyleDetailViewController: BaseViewController {

    private let mainView = StyleDetailView()
    
    var postData: Post?
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let postData else { return }
        mainView.configureDataSource()
        mainView.configureSnapshot(item: postData)
        
    }
    
    override func setHierarchy() {
        super.setHierarchy()
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
}
