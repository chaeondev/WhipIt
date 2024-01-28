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

- **프레임워크** : UIKit, Security(KeyChain)
- **디자인패턴** : MVVM, Singleton, Input/Output
- **라이브러리** : RxSwift, Moya, SnapKit, Kingfisher, YPImagePicker, IQKeyboardManager
- **의존성관리** : Swift Package Manager
- **ETC** : CodabaseUI, CompositionalLayout, DiffableDataSource, PropertyWrapper

---

> 주요기능

#### ✔︎ 회원가입, 로그인
- **정규표현식**을 사용하여 회원가입 유효성 검증, **RxSwift**에 기반한 로직 구현
- **JWT Token** 기반 로그인 구현 및 **KeyChain**을 통한 Token 정보 관리
- Alamofire의 **RequestInterceptor**를 활용해 **AccessToken** 갱신 및 **RefreshToken** 만료 로직 처리
- SplashView에서 Token 갱신 API를 이용해 **자동로그인 로직**을 통한 화면전환 분기 처리 및 사용성 개선

#### ✔︎ 포스트(게시글)
- **CompositionalLayout**과 **DiffableDataSource**를 사용해 이미지 사이즈에 기반한 **동적인** CollectionViewCell 레이아웃 피드 구현
- **Cursor Based Pagination** 구현을 통한 피드 데이터 실시간 갱신
- **NSAttributedString의 link**와 UITextViewDelegate method를 사용해 포스트 내 **해시태그 감지**
- **YPImagePicker** 라이브러리를 활용해 포스트 작성 시 자유로운 **이미지 커스터마이징** 제공
- **multipart/form-data** 형식을 통한 이미지, 텍스트 포함한 데이터 업로드 구현
- 

#### ✔︎ 네트워크

#### ✔︎ 기타
- **Rxswift** 기반 **MVVM Input/Output** 패턴을 적용해 비즈니스 로직 분리 및 코드 가독성 개선
- **Kingfisher**를 활용해 이미지 **캐싱** 및 **다운샘플링** 기능 기반 메모리 사용량 개선
- **PropertyWrapper**를 기반한 **UserDefaults**Manager를 통해 코드 재사용성 향상

---

<br> </br>
