//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 17/07/2024.
//

import Foundation

protocol RandomStringGenerating {
    
    func generateRandomString() -> String
}

struct RandomStringGenerator: RandomStringGenerating {
    
    func generateRandomString() -> String {
        UUID().uuidString
    }
}
