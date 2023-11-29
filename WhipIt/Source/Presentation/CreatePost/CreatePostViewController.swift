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
        view.contentMode = .scaleToFill
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
    
    var originalPhoto: UIImage = UIImage()
    
    var disposeBag = DisposeBag()
    let viewModel = CreatePostViewModel()
    
    
    var selectedItems = [YPMediaItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentImagePicker()
        setNavigationBar()
        bind()
    }
    
    private func bind() {
        
        let input = CreatePostViewModel.Input(
            registerBarButtonTap: navigationItem.rightBarButtonItem?.rx.tap,
            contentText: contentTextView.rx.text.orEmpty,
            imageData: originalPhoto.jpegData(compressionQuality: 0.8) ?? Data()
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
    
    @objc func registerButtonClicked() {
        
    }
    
    @objc func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        
        [photoImageView, reselectButton, contentTextView].forEach { view.addSubview($0) }
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        photoImageView.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.size.equalTo(130)
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
            make.height.equalTo(250)
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
                    self.originalPhoto = photo.originalImage
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

