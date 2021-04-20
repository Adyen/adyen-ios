//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A class for handling expiration timers
internal final class ExpirationTimer {
    
    /// :nodoc:
    private let expirationTimeout: TimeInterval
    
    /// :nodoc:
    private var timeLeft: TimeInterval
    
    /// :nodoc:
    private let tickInterval: TimeInterval
    
    /// :nodoc:
    private var timer: Timer?
    
    /// :nodoc:
    private let onTick: (TimeInterval) -> Void
    
    /// :nodoc:
    private let onExpiration: () -> Void
    
    /// Initializes `ExpirationTimer` object
    /// - Parameters:
    ///   - expirationTimeout: The time interval after which timer expires.
    ///   - tickInterval: The interval with which the timer ticks.
    ///   - onTick: The closure called on every timer tick.
    ///   - onExpiration: The closure called on timer expiration.
    internal init(
        expirationTimeout: TimeInterval,
        tickInterval: TimeInterval = 1.0,
        onTick: @escaping (TimeInterval) -> Void,
        onExpiration: @escaping () -> Void
    ) {
        self.expirationTimeout = expirationTimeout
        self.tickInterval = tickInterval
        self.timeLeft = expirationTimeout
        self.onTick = onTick
        self.onExpiration = onExpiration
    }
    
    /// :nodoc:
    internal func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.onTimerTick()
        }
    }
    
    /// :nodoc
    internal func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// :nodoc:
    private func onTimerTick() {
        timeLeft -= 1
        
        if timeLeft > 0 {
            onTick(timeLeft)
        } else {
            onExpiration()
        }
    }
}
