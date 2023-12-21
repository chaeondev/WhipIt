//
//  SelectPictureViewController.swift
//  WhipIt
//
//  Created by Chaewon on 11/27/23.
//

import UIKit
import RxSwift
import RxCocoa
import YPImagePicker
import Photos

class CreatePostViewController: BaseViewController {
    
    private lazy var photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.gray.cgColor
        return view
    }()
    
    let textPlaceholder = "#아이템과 #스타일을 자랑해보세요"
    
    private lazy var reselectButton: UIButton = {
        let button = UIButton.buttonBuilder(image: UIImage(systemName: "camera.fill"), title: " 사진 재선택", font: Font.light14)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(reselectButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var contentTextView: UITextView = {
        let view = UITextView()
        view.font = UIFont(name: Suit.light, size: 15)
        view.text = textPlaceholder
        view.textColor = .lightGray
        return view
    }()
    
    private lazy var button1 = HashTagButton(title: "#윈터템챌린지")
    private lazy var button2 = HashTagButton(title: "#오오티디")
    private lazy var button3 = HashTagButton(title: "#요즘아우터")
    private lazy var button4 = HashTagButton(title: "#연말코디")
    private lazy var button5 = HashTagButton(title: "#오뭐입")
    private lazy var button6 = HashTagButton(title: "#신발샷")
    private lazy var button7 = HashTagButton(title: "#겨울준비")
    private lazy var button8 = HashTagButton(title: "#라이징슈즈")
    
    private lazy var buttonStackView = {
        let view = UIStackView.stackViewBuilder(axis: .horizontal, distribution: .equalSpacing, spacing: 12, alignment: .fill)
        view.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    private lazy var scrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    private lazy var borderView = UIView.barViewBuilder(color: .systemGray5)
    
    private let selectedPhotoSubject = PublishSubject<UIImage>()
    
    var disposeBag = DisposeBag()
    let viewModel = CreatePostViewModel()
    
    
    var selectedItems = [YPMediaItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        presentImagePicker()
        setNavigationBar()
        bind()
    }
    
    private func bind() {
        
        let input = CreatePostViewModel.Input(
            registerBarButtonTap: navigationItem.rightBarButtonItem!.rx.tap,
            contentText: contentTextView.rx.text.orEmpty,
            imageData: selectedPhotoSubject.asObservable().map { $0.jpegData(compressionQuality: 0.8)},
            imageRatio: selectedPhotoSubject.asObservable().map {
                $0.size.width / $0.size.height
            }
        )
        
        let output = viewModel.transform(input: input)
        
        // textView Placeholder
        contentTextView.rx.didBeginEditing
            .bind(with: self) { owner, _ in
                if owner.contentTextView.text == owner.textPlaceholder {
                    owner.contentTextView.text = nil
                }
                owner.contentTextView.textColor = .black
            }
            .disposed(by: disposeBag)
        
        contentTextView.rx.didEndEditing
            .bind(with: self) { owner, _ in
                if owner.contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    owner.contentTextView.text = owner.textPlaceholder
                    owner.contentTextView.textColor = .lightGray
                }
            }
            .disposed(by: disposeBag)
        
        
        // 등록버튼 enable 처리
        output.registerValidation
            .bind(with: self) { owner, bool in
                owner.navigationItem.rightBarButtonItem?.isEnabled = bool
                owner.navigationItem.rightBarButtonItem?.tintColor = bool ? .black : .gray
            }
            .disposed(by: disposeBag)
        
        // post등록 네트워크 통신결과 처리
        output.postResponse
            .subscribe(with: self) { owner, result in
                switch result {
                case .success:
                    owner.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    var message: String {
                        switch error {
                        case .wrongRequest: 
                            return "사진 용량은 최대 10MB이하로 선택해주세요!"
                        case .forbidden:
                            return "접근권한이 없습니다"
                        default:
                            return "네트워크 서버 장애로 게시글이 저장되지 않았습니다. 다시시도해주세요"
                        }
                    }
                    owner.showAlertMessage(title: "게시글 등록 오류", message: message)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    private func setNavigationBar() {
        title = "스타일 올리기"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont(name: Suit.bold, size: 17)!
        ]
        let style = UINavigationBarAppearance()
        style.buttonAppearance.normal.titleTextAttributes = [.font: UIFont(name: Suit.bold, size: 15)!]
        navigationController?.navigationBar.standardAppearance = style
        
        let registerButton = UIBarButtonItem(title: "등록", style: .plain, target: self, action: nil)
        registerButton.tintColor = .black
        navigationItem.rightBarButtonItem = registerButton
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(backButtonClicked))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func reselectButtonClicked() {
        presentImagePicker()
    }

    @objc func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func autoHashTagButtonClicked(_ sender: UIButton) {
        guard let autoText = sender.titleLabel?.text else { return }
        if let originalText = contentTextView.text, originalText != self.textPlaceholder {
            contentTextView.text = originalText + autoText
            contentTextView.refreshControl?.sendActions(for: .valueChanged)
        } else {
            contentTextView.text = autoText
            contentTextView.refreshControl?.sendActions(for: .valueChanged)
        }
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        [button1, button2, button3, button4, button5, button6, button7, button8].forEach { buttonStackView.addArrangedSubview($0) }
        [button1, button2, button3, button4, button5, button6, button7, button8].forEach {
            $0.addTarget(self, action: #selector(autoHashTagButtonClicked), for: .touchUpInside)
        }
        
        scrollView.addSubview(buttonStackView)
        [photoImageView, reselectButton, contentTextView, scrollView, borderView].forEach { view.addSubview($0) }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        photoImageView.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.size.equalTo(100)
        }
        
        reselectButton.snp.makeConstraints { make in
            make.bottom.equalTo(photoImageView.snp.bottom)
            make.leading.equalTo(photoImageView.snp.trailing).offset(16)
            make.height.equalTo(35)
            make.width.equalTo(110)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(25)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(30)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
    }
    
}

extension CreatePostViewController: YPImagePickerDelegate {
    
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        print("사진이 없습니다.")
    }
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        true
    }
    
    func presentImagePicker() {
        let config = setImagePickerConfiguration()
        
        let imagePicker = YPImagePicker(configuration: config)
        imagePicker.imagePickerDelegate = self
        
        imagePicker.didFinishPicking { [weak imagePicker] items, cancelled in
            if cancelled {
                imagePicker?.dismiss(animated: true)
                if self.photoImageView.image == nil {
                    self.navigationController?.popViewController(animated: false)
                }
            }
            
            self.selectedItems = items
            if let singlePhoto = items.first {
                switch singlePhoto {
                case .photo(let photo):
                    self.photoImageView.image = photo.image
                    self.selectedPhotoSubject.onNext(photo.originalImage)
                    //self.originalPhoto = photo.originalImage
                    print("=====111111=======")
                    imagePicker?.dismiss(animated: true)
                default:
                    imagePicker?.dismiss(animated: true)
                    
                }
            }
        }
        
        imagePicker.modalPresentationStyle = .overFullScreen
        present(imagePicker, animated: true)
    }
    
    func setImagePickerConfiguration() -> YPImagePickerConfiguration {
        var config = YPImagePickerConfiguration()
        
        config.startOnScreen = .library
        config.showsPhotoFilters = false
        config.library.defaultMultipleSelection = false
        config.library.mediaType = .photo
        config.hidesBottomBar = true
        config.showsCrop = .none
        
        return config
    }
    
}

