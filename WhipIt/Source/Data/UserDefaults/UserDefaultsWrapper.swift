//
//  UserDefaultsWrapper.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper<T> {
    let key: UserDefaultsKey
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key.rawValue)
        }
    }
}
