//
//  Available.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 10/4/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Foundation

enum Available {
    static var iOS12: Bool {
        if #available(iOS 12.0, *) {
            return true
        } else {
            return false
        }
    }
    
    static var iOS13: Bool {
        if #available(iOS 13.0, *) {
            return true
        } else {
            return false
        }
    }
    
    static var iOS17: Bool {
        if #available(iOS 17.0, *) {
            return true
        } else {
            return false
        }
    }
}
