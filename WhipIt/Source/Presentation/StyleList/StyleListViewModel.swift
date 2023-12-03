//
//  StyleListViewModel.swift
//  WhipIt
//
//  Created by Chaewon on 11/30/23.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher

class StyleListViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let searchButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let getPostResponse: PublishSubject<NetworkResult<GetPostResponse>>
        let imageRelayList: BehaviorRelay<[RetrieveImageResult]>
    }
    
    func transform(input: Input) -> Output {
        
        let getPostResponse = PublishSubject<NetworkResult<GetPostResponse>>()
        let imageRelayList = BehaviorRelay<[RetrieveImageResult]>(value: [])
        
        APIManager.shared.requestGetPost(limit: 10)
            .asObservable()
            .subscribe(with: self) { owner, result in
                getPostResponse.onNext(result)
                switch result {
                case .success(let response):
                    response.data.forEach {
                        let modifier = AnyModifier { request in
                            var requestBody = request
                            requestBody.setValue(KeyChainManager.shared.accessToken, forHTTPHeaderField: "Authorization")
                            requestBody.setValue(APIKey.sesacKey, forHTTPHeaderField: "SesacKey")
                            return requestBody
                        }
                        
                        let url = URL(string: APIKey.baseURL + $0.image.first!)!
                        
                        KingfisherManager.shared.retrieveImage(with: url, options: [.requestModifier(modifier)]) { result in
                            switch result {
                            case .success(let value):
                                
                                var list = imageRelayList.value
                                list.append(value)
                                imageRelayList.accept(list)
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    
        return Output(getPostResponse: getPostResponse, imageRelayList: imageRelayList)
    }
}

