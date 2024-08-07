//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 07/08/2024.
//

import Foundation

struct IndependentChange: Equatable {
    enum ChangeType: Equatable {
        case addition(_ description: String)
        case removal(_ description: String)

        var description: String {
            switch self {
            case .addition(let description): description
            case .removal(let description): description
            }
        }
    }

    let changeType: ChangeType
    let element: SDKDump.Element

    let oldFirst: Bool
    var parentName: String { element.parentPath }
}
