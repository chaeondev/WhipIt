//
//  ProfileSettingViewController.swift
//  WhipIt
//
//  Created by Chaewon on 12/17/23.
//

import UIKit
import RxSwift
import RxCocoa
import YPImagePicker
import Photos

final class ProfileSettingViewController: BaseViewController {
    
    private lazy var profileImageView = {
        let view = RoundImageView(frame: .zero)
        view.backgroundColor = .systemGray5
        view.image = UIImage(systemName: "star")
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var imageEditButton = UIButton.buttonBuilder(title: "프로필 사진 수정", font: UIFont(name: Suit.medium, size: 14)!, titleColor: .systemBlue)

    
    private lazy var profileButton = UIButton()
    
    private lazy var profileInfoLabel = UILabel.labelBuilder(text: "프로필 정보", font: UIFont(name: Suit.bold, size: 20)!, textColor: .black)
    private lazy var emailView = SettingView(type: .emailID)
    private lazy var nicknameView = SettingView(type: .nickname)
    private lazy var phoneView = SettingView(type: .phoneNum)
    
    private lazy var logoutButton = {
        let view = UIButton.buttonBuilder(title: "로그아웃", font: UIFont(name: Suit.medium, size: 14), titleColor: .systemRed)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private lazy var withdrawButton = {
        let view = UIButton.buttonBuilder(title: "회원탈퇴", font: UIFont(name: Suit.medium, size: 14), titleColor: .darkGray)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private let selectedPhotoSubject = PublishSubject<UIImage>()
    var selectedItems = [YPMediaItem]()
    
    var profile: GetMyProfileResponse?
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
    
    func bind() {
        profileButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.presentImagePicker()
            }
            .disposed(by: disposeBag)
        
        nicknameView.editButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = EditProfileViewController()
                vc.profileInfo = owner.profile
                vc.editType = .nickname
                vc.delegate = self
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .pageSheet
                
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        phoneView.editButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = EditProfileViewController()
                vc.profileInfo = owner.profile
                vc.editType = .phone
                vc.delegate = self
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .pageSheet
                
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureView() {
        guard let profile else { return }
        profileImageView.setKFImage(imageUrl: profile.profile ?? "")
        emailView.editButton.isHidden = true
        emailView.contentLabel.text = profile.email
        nicknameView.contentLabel.text = profile.nick
        phoneView.contentLabel.text = profile.phoneNum
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        [profileImageView, imageEditButton, profileButton, profileInfoLabel, emailView, nicknameView, phoneView, logoutButton, withdrawButton].forEach { view.addSubview($0) }
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        
        imageEditButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        //profileButton.backgroundColor = .black.withAlphaComponent(0.5)
        profileButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.bottom.equalTo(imageEditButton)
            make.centerX.equalToSuperview()
            make.width.equalTo(imageEditButton)
        }
        
        profileInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(profileButton.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        //emailView.backgroundColor = .blue.withAlphaComponent(0.5)
        emailView.snp.makeConstraints { make in
            make.top.equalTo(profileInfoLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(90)
        }
        
        nicknameView.snp.makeConstraints { make in
            make.top.equalTo(emailView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(90)
        }
        
        phoneView.snp.makeConstraints { make in
            make.top.equalTo(nicknameView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(90)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(phoneView.snp.bottom).offset(30)
            make.centerX.equalToSuperview().multipliedBy(0.5)
            make.width.equalTo(180)
            make.height.equalTo(35)
        }
        
        withdrawButton.snp.makeConstraints { make in
            make.top.equalTo(phoneView.snp.bottom).offset(30)
            make.centerX.equalToSuperview().multipliedBy(1.5)
            make.width.equalTo(180)
            make.height.equalTo(35)
        }
    }
}

extension ProfileSettingViewController: YPImagePickerDelegate {
    
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
                    let photoData = photo.image.jpegData(compressionQuality: 0.4)
                    let editRequest = EditMyProfileRequest(nick: nil, phoneNum: nil, profile: photoData)
                    APIManager.shared.requestEditMyProfile(model: editRequest)
                        .asObservable()
                        .subscribe(with: self) { owner, result in
                            switch result {
                            case .success(let response):
                                owner.profileImageView.setKFImage(imageUrl: response.profile ?? "")
                                imagePicker?.dismiss(animated: true)
                            case .failure(let error):
                                imagePicker?.dismiss(animated: true)
                                var message: String {
                                    switch error {
                                    case .wrongRequest: "사진 용량은 최대 1MB 이하로 선택해주세요!"
                                    default: "네트워크 서버 장애로 프로필 사진이 수정되지 않았습니다. 다시시도해주세요"
                                    }
                                }
                                owner.showAlertMessage(title: "프로필 사진 수정 오류", message: message)
                            }
                        }
                        .disposed(by: self.disposeBag)
                    
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

extension ProfileSettingViewController: EditDelegate {
    func updateProfile(info: GetMyProfileResponse) {
        self.profile = info
        configureView()
    }
}
