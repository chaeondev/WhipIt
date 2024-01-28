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
- 게시글에 해시태그 추가 가능, 해시태그 기반으로 게시글 필터링 기능 제공
- 북마크, 댓글을 통해 다른 유저와 소통 가능
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

#### ✔︎ 회원가입, 로그인
- **정규표현식**을 사용하여 회원가입 유효성 검증, **RxSwift**에 기반한 로직 구현
- **JWT Token** 기반 로그인 구현 및 **KeyChain**을 통한 Token 정보 관리
- Alamofire의 **RequestInterceptor**를 활용해 **AccessToken** 갱신 및 **RefreshToken** 만료 로직 처리
- SplashView에서 Token 갱신 API를 이용해 **자동로그인 로직**을 통한 화면전환 분기 처리

#### ✔︎ 포스트
- **CompositionalLayout**를 사용해 이미지 비율 기반 **dynamic** CollectionViewCell 레이아웃 피드 구현
- **DiffableDataSource** 기반 섹션 별 **Hashable**한 데이터 모델과 **스냅샷**을 통해 UI 상태 관리 및 interactive한 사용자 경험 제공
- **Cursor Based Pagination** 구현을 통한 피드 데이터 실시간 갱신
- **NSAttributedString의 link**와 UITextViewDelegate method를 사용해 포스트 내 **해시태그 감지**
- **YPImagePicker** 라이브러리를 활용해 포스트 작성 시 자유로운 **이미지 커스터마이징** 제공
- **multipart/form-data** 형식을 통한 이미지, 텍스트 포함한 데이터 업로드 구현

#### ✔︎ 네트워크
- **RxSwift Single Trait**을 사용해 네트워크 요청 로직 구현 
- Moya를 통해 네트워크 계층 **Router Pattern** 구성, **Generic** 기반 Request 메서드 구현을 통해 **코드 추상화**
- enum을 활용해 status code 기반 네트워크 **에러 핸들링**

#### ✔︎ 기타
- **Rxswift** 기반 **MVVM Input/Output** 패턴을 적용해 비즈니스 로직 분리 및 코드 가독성 개선
- **Kingfisher** 이미지 **캐싱** 및 **다운샘플링** 기능을 통해 메모리 사용량 개선
- **PropertyWrapper**를 기반한 **UserDefaults**Manager를 구현하여 코드 재사용성 향상
- **접근제어자** final, private를 사용하여 **Static Dispatch**를 이용한 컴파일 최적화 및 은닉화

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
func request<T: Decodable>(target: LSLPAPI) -> Single<NetworkResult<T>> {
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

#### Solution

<br> </br>

### 3. Kingfisher 비동기 이미지 다운로드로 인한 피드 Layout 이슈

#### Issue
#### Solution

<br> </br>

### 4. 댓글 문구 버튼으로 댓글 Post시 값 전달 에러 

#### Issue
#### Solution

<br> </br>

## 회고

### ▹ 배운점



### ▹ 아쉬운점

