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
        view.backgroundColor = .blue
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
        view.delegate = self
        return view
    }()
    
    
    var selectedItems = [YPMediaItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentImagePicker()
        setNavigationBar()
    }
    
    private func setNavigationBar() {
        title = "스타일 올리기"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont(name: Suit.bold, size: 17)!
        ]
        let style = UINavigationBarAppearance()
        style.buttonAppearance.normal.titleTextAttributes = [.font: UIFont(name: Suit.bold, size: 15)!]
        navigationController?.navigationBar.standardAppearance = style
        
        let registerButton = UIBarButtonItem(title: "등록", style: .plain, target: self, action: #selector(registerButtonClicked))
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
            }
            
            self.selectedItems = items
            if let singlePhoto = items.first {
                switch singlePhoto {
                case .photo(let photo):
                    self.photoImageView.image = photo.image
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

extension CreatePostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.text == textPlaceholder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            contentTextView.text = textPlaceholder
            contentTextView.textColor = .lightGray
        }
    }
}
