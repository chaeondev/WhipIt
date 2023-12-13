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
    
    private let commentView = CommentView()
    
    var postData: Post?
    
    private let viewModel = StyleDetailViewModel()
    
    private var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let postData else { return }
        mainView.configureDataSource()
        mainView.configureSnapshot(item: postData)
        tabBarController?.tabBar.isHidden = true
        
        bind()
    }
    
    private func bind() {
        
        guard let postData else { return }
        
        let input = StyleDetailViewModel.Input(
            commentText: commentView.commentTextField.rx.text.orEmpty,
            registerButtonTap: commentView.commentTextField.registerButton.rx.tap, 
            postID: postData._id
        )
        let output = viewModel.transform(input: input)
        
        output.commentValidation
            .bind(with: self) { owner, value in
                owner.commentView.commentTextField.registerButton.isEnabled = value
                owner.commentView.commentTextField.registerButton.setTitleColor(value ? .black : .gray, for: .normal)
            }
            .disposed(by: disposeBag)
        
        output.commentResponse
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    owner.mainView.applySnapshot(items: [response])
                    owner.commentView.commentTextField.text = ""
                case .failure(let error):
                    var message: String {
                        switch error {
                        case .wrongRequest:
                            return "댓글 내용을 작성해주세요!"
                        case .notFound:
                            return "댓글을 추가할 게시글을 찾을 수 없습니다."
                        default:
                            return "네트워크 서버 장애로 댓글이 작성되지 않았습니다. 다시 시도해주세요"
                        }
                    }
                    owner.showAlertMessage(title: "댓글 등록 오류", message: message)
                }
            }
            .disposed(by: disposeBag)
        
        

    }
    
    override func setHierarchy() {
        super.setHierarchy()
        view.addSubview(commentView)
    }
    
    override func setConstraints() {
        super.setConstraints()
        commentView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.greaterThanOrEqualTo(130)
        }
        
    }
}
