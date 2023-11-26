//
//  UserDefaultsManager.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import Foundation

enum UserDefaultsManager {
    
    @UserDefaultsWrapper(key: .isLaunched, defaultValue: false)
    static var isLaunched // 최초 앱 실행 여부
    
    @UserDefaultsWrapper(key: .isLogin, defaultValue: false)
    static var isLogin // 로그인 여부
}
