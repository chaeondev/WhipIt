//
//  ViewModelType.swift
//  WhipIt
//
//  Created by Chaewon on 11/19/23.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
