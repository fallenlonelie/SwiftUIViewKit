//
//  SecondViewModel.swift
//  SwiftUIViewKitSampleApp
//
//  Created by LONELiE on 2023/02/16.
//

import Foundation

struct SecondViewModel: ViewModel {
    var list: [String] = ["1", "2", "3", "4", "5", "A", "B", "C", "D", "E", "F", "G"]
}

extension ViewModel.Relay where Element == SecondViewModel {
    
}
