//
//  OrderStatusRequest.swift
//  Adyen
//
//  Created by Mohamed Eldoheiri on 5/6/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Foundation

/// :nodoc:
public struct OrderStatusRequest: Request {

    /// :nodoc:
    public typealias ResponseType = OrderStatusResponse

    /// :nodoc:
    public var path: String { "checkoutshopper/v1/order/status" }

    /// :nodoc:
    public var counter: UInt = 0

    /// :nodoc:
    public let headers: [String: String] = [:]

    /// :nodoc:
    public let queryParameters: [URLQueryItem] = []

    /// :nodoc:
    public let method: HTTPMethod = .get

    /// :nodoc:
    public let orderData: String

    /// :nodoc:
    public init(orderData: String) {
        self.orderData = orderData
    }

    /// :nodoc:
    public enum CodingKeys: CodingKey {
        case orderData
    }

}
