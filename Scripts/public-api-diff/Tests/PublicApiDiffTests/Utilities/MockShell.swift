//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 24/06/2024.
//

@testable import public_api_diff
import XCTest

struct MockShell: ShellHandling {
    
    var handleExecute: (String) -> String
    
    @discardableResult
    func execute(_ command: String) -> String {
        handleExecute(command)
    }
}
