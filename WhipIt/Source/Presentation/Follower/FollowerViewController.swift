//
//  FollowerViewController.swift
//  WhipIt
//
//  Created by Chaewon on 12/21/23.
//

import UIKit

enum FollowType {
    case follower, following
}

final class FollowerViewController: BaseViewController {
    
    private lazy var segmentedControl = {
        let followerCnt = profile.followers.count
        let followingCnt = profile.following.count
        let view = UnderlineSegmentedControl(items: ["\(followerCnt)\n팔로워", "\(followingCnt)\n팔로잉"])
        view.selectedSegmentIndex = followType == .follower ? 0 : 1
        view.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return view
    }()
    
    private lazy var tableView = {
        let view = UITableView()
        view.register(FollowerTableCell.self, forCellReuseIdentifier: "followerTableCell")
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.rowHeight = 100
        return view
    }()
    
    var accountType: AccountType!
    var followType: FollowType = .follower
    var followList: [User] = []
    var profile: GetProfileResponse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigation()
        setFollowList()
    }
    
    private func setNavigation() {
        title = profile.nick
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont(name: Suit.bold, size: 17)!
        ]
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func setFollowList() {
        followList = (followType == .follower) ? profile.followers : profile.following
    }
    
    @objc func segmentedControlValueChanged() {
        followList = {
            switch segmentedControl.selectedSegmentIndex {
            case 0: return profile.followers
            case 1: return profile.following
            default: return []
            }
        }()
        tableView.reloadData()
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        [segmentedControl, tableView].forEach { view.addSubview($0) }
    }
    
    override func setConstraints() {
        super.setConstraints()
        segmentedControl.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(55)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension FollowerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "followerTableCell") as? FollowerTableCell else { return UITableViewCell() }
        
        let data = followList[indexPath.row]
        cell.userData = data
        cell.getUserProfile()
        cell.getUserPost()
        cell.configureCell()
        cell.delegate = self
        
        if data._id == KeyChainManager.shared.userID {
            cell.followButton.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = followList[indexPath.row]
        let vc = MyAccountViewController()
        vc.accountType = (data._id == KeyChainManager.shared.userID) ? .me : .user
        vc.userID = data._id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension FollowerViewController: TableCellDelegate {
    
    func transitionView(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
    
    func showAlert(title: String, message: String) {
        self.showAlertMessage(title: title, message: message)
    }
}

