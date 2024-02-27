<p align="left">
  <img width="100" alt="image" src="https://github.com/chaeondev/WhipIt/assets/80023607/51748942-02be-49fd-adc8-9b4b88501c80">
</p>

# WhipIt

#### 일상의 스타일을 공유하고 해시태그 기반 검색이 가능한 커뮤니티 형식의 SNS 앱입니다.

## Preview
<img width="1000" alt="image" src="https://github.com/chaeondev/WhipIt/assets/80023607/8e834e8b-3f61-4687-8ac6-7996526a513e">

<img width="1000" alt="image" src="https://github.com/chaeondev/WhipIt/assets/80023607/78957236-d5d1-4db4-950b-2b7e8a22e628">
<br></br>

## 프로젝트 소개

> 앱 소개
- 회원가입, 로그인, 로그아웃, 회원탈퇴 기능 제공
- 사진과 텍스트를 기반한 게시글을 피드 형식으로 보여줌
- 게시글에 북마크, 댓글 작성 가능
- 해시태그 추가 가능, 해시태그 기반으로 게시글 필터링 기능 제공
- 다른 유저를 팔로우하고 프로필 확인 가능
- 나의 프로필에서 게시글, 팔로우 관리 기능 제공

---

> 서비스
- **개발인원** : 1인 개발
- **개발기간** : 2023.11.16 - 2023.12.20
- **협업툴** : Git, Figma
- **iOS Deployment Target** : iOS 16.0

---

> 기술스택

- **프레임워크** : UIKit
- **디자인패턴** : MVVM, Singleton, Input/Output
- **라이브러리** : RxSwift, Moya, SnapKit, Kingfisher, YPImagePicker, IQKeyboardManager
- **의존성관리** : Swift Package Manager
- **ETC** : CodabaseUI, CompositionalLayout, DiffableDataSource, PropertyWrapper, KeyChain

---

> 주요기능

- **Rxswift** 기반 **MVVM Input/Output** 패턴을 적용해 비즈니스 로직 분리 및 코드 가독성 개선
- **Kingfisher** 이미지 **캐싱** 및 **다운샘플링** 기능을 통해 메모리 사용량 개선
- **PropertyWrapper**를 기반한 **UserDefaultsManager**를 구현하여 코드 재사용성 향상
- **접근제어자** final, private를 사용하여 **Static Dispatch**를 이용한 컴파일 최적화 및 은닉화

#### ✔︎ 회원가입, 로그인
- **Regular Experession**을 사용하여 회원가입 유효성 검증, **RxSwift**에 기반한 반응형 UI 구현
- **JWT Token** 기반 로그인 구현 및 **KeyChain**을 통한 Token 정보 관리
- Alamofire의 **RequestInterceptor**를 활용해 **AccessToken** 갱신 및 **RefreshToken** 만료 로직 처리
- SplashView에서 Token 갱신 API를 이용해 **자동로그인** 로직 구현

#### ✔︎ 포스트
- **CompositionalLayout**를 사용해 이미지 비율 기반 **dynamic** CollectionViewCell 레이아웃 피드 구현
- **DiffableDataSource** 기반 섹션 별 **Hashable**한 데이터 모델과 **스냅샷**을 통해 UI 상태 관리 및 interactive한 사용자 경험 제공
- **Cursor Based Pagination** 구현을 통한 피드 데이터 실시간 갱신
- **NSAttributedString의 link**와 UITextViewDelegate method를 사용해 포스트 내 **해시태그 감지**
- **YPImagePicker** 라이브러리를 활용해 포스트 작성 시 **이미지 커스터마이징** 제공
- **multipart/form-data** 형식을 통한 이미지, 텍스트 포함한 데이터 업로드 구현

#### ✔︎ 네트워크
- **RxSwift Single Trait**을 사용해 네트워크 요청 로직 구현 
- Moya를 통해 네트워크 계층 **Router Pattern** 구성, **Generic** 기반 Request 메서드 구현을 통해 **코드 추상화**
- enum을 활용해 status code 기반 네트워크 **에러 핸들링**

---

<br> </br>

## 트러블 슈팅

### 1. RxSwift Single의 특성으로 인한 Subscribe 이슈

#### Issue
네트워크 Request 로직에 Single을 사용하면 명시적으로 성공 혹은 실패 여부만을 관리할 수 있기 때문에 **Single을 Wrapping**해서 구현했습니다. 
네트워크 통신 성공 시 문제가 없었지만, 통신 에러가 발생했을 때 `single(.failure(error))`로 return할 경우(즉, `onError`로 방출) ViewModel 로직에서 문제가 발생했습니다.
**API Request method를** 단일 Stream으로 사용할 경우는 괜찮았지만, **flatMap과 같은 operator로 Stream을 결합하여 사용할 경우 dispose로 인해 구독이 끊기는 현상**을 찾을 수 있었습니다.

이로 인해 회원가입 버튼 클릭 이벤트와 API Request가 결합된 경우, 네트워크 에러 발생 시 구독이 끊기기 때문에 버튼을 다시 클릭해도 이벤트가 발생하지 않았습니다.

#### Solution
NetworkResult를 성공, 실패 여부와 관계없이 single의 success 이벤트로 발행함으로써, 구독을 유지시켰습니다. 
그리고 NetworkResult 자체적으로 성공과 실패를 분리해 에러 핸들링을 처리할 수 있었습니다.
이를 통해 네트워크 통신 에러가 발생하더라도 Stream 구독이 끊기는 현상을 방지할 수 있었습니다.

* enum으로 NetworkResult 생성
```swift
enum NetworkResult<T: Decodable> {
    case success(T)
    case failure(APIError)
}
```
* request method 반환값 `Single<NetworkResult<T>>`로 설정
```swift
func request<T: Decodable>(target: APIRouter) -> Single<NetworkResult<T>> {
    return Single<NetworkResult<T>>.create { single in
        self.provider.request(target) { result in
            switch result {
            case .success(let response):
                guard let decodedData = try? JSONDecoder().decode(T.self, from: response.data) else {
                    single(.success(.failure(.invalidData)))
                    return
                }
                return single(.success(.success(decodedData)))
                // 성공의 경우 single의 success이벤트 안에 NetworkResult의 success 추가

            case .failure(let error):
                guard let statusCode = error.response?.statusCode, let networkError = APIError(rawValue: statusCode) else {
                    single(.success(.failure(.serverError)))
                    return
                }
                single(.success(.failure(networkError)))
                //실패의 경우에도 success 이벤트 안에 NetworkResult에서 failure처리

            }
        }
        return Disposables.create()
    }
}

```
<br> </br>

### 2. Interceptor에서 retry할 때 refreshToken API 호출 에러

#### Issue
Alamofire의 RequestInterceptor를 사용해 Token 관리를 진행했습니다. 
adapt method를 통해 네트워크 request 전에 accessToken이 필요한 API에 header로 삽입해주고, retry method에서 네트워크 실패시 refreshToken API를 통해 accessToken을 갱신하는 로직을 구현했습니다. 
그러나 accessToken이 만료되어 retry method가 실행되고, **refresh Token API가 진행되는 시점에 Moya sync error가 발생**했습니다. 

#### Solution
처음에는 retry 내의 refreshToken 네트워크 Stream에 `.observe(on: MainScheduler.asyncInstance)`을 추가해서 오류는 막을 수 있었습니다. 
하지만 네트워크 통신 로직을 Main thread에서 하는게 맞는가에 대한 의문이 들었습니다. 
RxSwift의 Scheduler에 대해 찾아보게 되었고 MainSchduler 자체가 SerialDispatchQueueScheduler의 한 종류라는 것을 알 수 있었습니다.
그 중 `SerialDispatchQueueScheduler.init(qos: .userInitiated)`를 찾을 수 있었습니다. 
`userInitiated`는 유저가 실행시킨 작업들을 즉각적이지는 않지만, async하게 처리해주었고 이게 에러를 방지하면서 네트워크 통신에 적절한 Scheduler라고 판단했습니다.

```swift
 func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    print("retry 진입")
    guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 419 else {
        completion(.doNotRetryWithError(error))
        return
    }

    let task = Observable.just(())
    
    task
      .observe(on: SerialDispatchQueueScheduler.init(qos: .userInitiated))
      .flatMap { APIManager.shared.refreshToken() }
      .subscribe(with: self) { owner, result in
          switch result {
          case .success(let response):
              KeyChainManager.shared.create(account: .accessToken, value: response.token)
              completion(.retry)
              
          case .failure(let error):

              if [401, 418].contains(error.rawValue) {
                  owner.reLogin()
              }
              completion(.doNotRetryWithError(error))
          }
      }
      .disposed(by: disposeBag)
    
}
```

<br> </br>

### 3. Kingfisher 비동기 이미지 다운로드로 인한 피드 Layout 이슈

#### Issue
게시글 피드를 이미지의 사이즈 비율을 기반으로 dynamic한 CollectionView Cell을 이용해 레이아웃을 구성하고자 했습니다.
하지만 **Kingfisher**를 통해 서버에서 이미지를 다운로드 하는 과정이 **비동기로 동작**하기 때문에 **이미지 다운로드가 완료되지 않은 채로 cell의 layout을 잡게되는 문제**가 발생했습니다. 

#### Solution
이를 해결하기 위해서 다양한 방법을 고민했습니다. 네트워크 통신으로 게시글 데이터를 전달 받은 후 다시 CollectionView layout을 업데이트 해주는 로직으로 구성했기 때문에 이미지 데이터 뿐만 아니라 게시글 자체의 데이터 또한 고려해야 했습니다.
그렇기에 이미지 다운로드가 끝나면 completionHandler를 통해 알리고 layout을 잡는 방법은 적절하지 않았습니다. 문제는 생각보다 간단한 방법으로 해결할 수 있었습니다. 게시글 작성 후 서버로 데이터를 전달할 시 모델 자체에 이미지의 비율을 미리 계산해 전달했습니다. 이를 통해 이미지 다운로드 여부와 관계없이 동적인 layout을 구성할 수 있었습니다.

* Post Request Model에 이미지 비율 데이터 추가

```swift
struct CreatePostRequest: Encodable {
    let product_id: String
    let content: String
    let file: Data
    let fileRatio: String
}
```
* Post 네트워크 통신 전 이미지 비율 계산

```swift
input.imageRatio
    .filter { $0 != 0.0 }
    .map {
        return String(format: "%.2f", $0)
    }
    .bind(to: ratio)
    .disposed(by: disposeBag)
```
* 게시글 네트워크 GET 이후 레이아웃 업데이트

```swift
output.feedResult
  .subscribe(with: self) { owner, result in
      switch result {
      case .success(let response):
          owner.postList.append(contentsOf: response.data)
          owner.nextCursor = response.next_cursor
          let ratios = response.data.map {
              let floatRatio: CGFloat = CGFloat(NSString(string: $0.fileRatio).floatValue) //POST 때 서버에 전달한 이미지 비율 이용
              return Ratio(ratio: floatRatio * 0.75)
          }
          let layout = PinterestLayout(columnsCount: 2, itemRatios: ratios, spacing: 10, contentWidth: owner.view.frame.width)
          
          owner.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: layout.section)
          
          owner.configureSnapshot(response)
      case .failure(let error):
          print(error.localizedDescription)
      }
  }
  .disposed(by: disposeBag)
```

<br> </br>

