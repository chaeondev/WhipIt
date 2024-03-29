//
//  SplashViewController.swift
//  WhipIt
//
//  Created by Chaewon on 12/5/23.
//

import UIKit
import RxSwift
import RxCocoa

class SplashViewController: BaseViewController {
    
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = .whipIt
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let viewModel = SplashViewModel()
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        let input = SplashViewModel.Input()
        let output = viewModel.transform(input: input)
        
        //자동로그인
        output.autoLoginValidation
            .bind(with: self) { owner, data in
                switch data {
                case .accept:
                    print("===자동 로그인 -> TabBar ===")
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(owner.setTabBarController())
                case .reject:
                    print("=== 자동 로그인 실패 -> LoginVC ===")
                    let loginVC = UINavigationController(rootViewController: LoginViewController())
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginVC)
                case .nothing:
                    print("대체 왜 nothing?? 자동로그인에 문제생김")
                }
            }
            .disposed(by: disposeBag)

    }
    
    override func setHierarchy() {
        super.setHierarchy()
        view.addSubview(logoImageView)
    }
    
    override func setConstraints() {
        super.setConstraints()
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(250)
            make.height.equalTo(150)
        }
    }
    
    private func setTabBarController() -> UITabBarController {
        let tabBar = UITabBarController()
        
        let styleVC = UINavigationController(rootViewController: StyleListViewController())
        styleVC.tabBarItem = UITabBarItem(title: "STYLE", image: UIImage(systemName: "heart.text.square"), selectedImage: UIImage(systemName: "heart.text.square.fill"))
        let bookmarkVC = UINavigationController(rootViewController: BookMarkViewController())
        bookmarkVC.tabBarItem = UITabBarItem(title: "SAVED", image: UIImage(systemName: "bookmark"), selectedImage: UIImage(systemName: "bookmark.fill"))
        let accountVC = MyAccountViewController()
        accountVC.accountType = .me
        accountVC.userID = KeyChainManager.shared.userID
        let accountNav = UINavigationController(rootViewController: accountVC)
        accountNav.tabBarItem = UITabBarItem(title: "MY", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        tabBar.viewControllers = [styleVC, bookmarkVC, accountNav]
        tabBar.tabBar.tintColor = .black
        
        return tabBar
    }
}
