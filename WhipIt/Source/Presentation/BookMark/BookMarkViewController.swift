//
//  BookMarkViewController.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import UIKit
import RxSwift
import RxCocoa

class BookMarkViewController: BaseViewController {
    
    private lazy var countLabel = UILabel.labelBuilder(text: "전체 5", font: UIFont(name: Suit.medium, size: 15)!, textColor: .black)
    private lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        view.register(BookMarkCell.self, forCellWithReuseIdentifier: "cell")
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    var postList: [Post] = []
    var nextCursor: String = ""
    
    private let viewModel = BookMarkViewModel()
    
    private var disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bind()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
    }
    
    private func bind() {
        let input = BookMarkViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.postList
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    owner.countLabel.text = "전체 \(response.data.count)"
                    owner.postList = response.data
                    owner.nextCursor = response.next_cursor
                    owner.collectionView.reloadData()
                    
                case .failure(let error):
                    print("=======북마크 리스트 에러======", error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func setNavigationBar() {
        title = "Saved"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font : Font.extraBold34
        ]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        
        view.addSubview(countLabel)
        view.addSubview(collectionView)
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        countLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(20)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension BookMarkViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? BookMarkCell else { return UICollectionViewCell() }
        
        let post = postList[indexPath.item]
        cell.imageView.setKFImage(imageUrl: post.image.first ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 6
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let size = UIScreen.main.bounds.width - (spacing * 2 + 1)
        let width = size / 3
        let height = width
        layout.itemSize = CGSize(width: width, height: height)
        return layout
    }
}
