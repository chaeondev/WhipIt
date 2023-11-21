//
//  APIError.swift
//  WhipIt
//
//  Created by Chaewon on 11/21/23.
//

import Foundation

enum APIError: Int, Error {
    case wrongRequest = 400 // requestBody 필수값 누락/ 포스트의 경우 파일의 제한사항 안맞을때
    case unAuthorized = 401 // 회원가입 미가입, 비밀번호 불일치 / 유효하지 않는 액세스 토큰 요청
    case forbidden = 403 // 접근권한이 없는경우
    case serverConflict = 409 // 이미 서버에 정보 있을때/ token 만료 안되었을때
    case notFound = 410 // 생성된 게시글 없음(DB서버장애로 게시글 저장안됨), 수정삭제할 게시글 못찾음(삭제된 게시글일 경우), 댓글 추가할 게시글 못찾음
    case refreshTokenExpired = 418 // 리프레시 토큰 만료
    case accessTokenExpired = 419 // 액세스 토큰 만료
    case invalidKey = 420 // 유효하지 않은 키
    case overcall = 429 // 과호출
    case invalidURL = 444 // 비정상 URL 요청
    case permissionDenied = 445 // 게시글 수정삭제 권한 없음(본인글만 수정가능), 댓글 수정삭제 권한 없음
    case serverError = 500 // 사전에 정의되지 않는 에러
    case invalidData = 0 // reponse Data 변환 엥러
    case statusError
}
