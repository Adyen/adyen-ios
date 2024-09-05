//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A class for handling expiration timers
internal final class ExpirationTimer {
    
    private let expirationTimeout: TimeInterval
    
    private var timeLeft: TimeInterval
    
    private var timer: Timer?
    
    private let onTick: (TimeInterval) -> Void
    
    private let onExpiration: () -> Void
    
    /// Initializes `ExpirationTimer` object
    /// - Parameters:
    ///   - expirationTimeout: The time interval after which timer expires.
    ///   - tickInterval: The interval with which the timer ticks.
    ///   - onTick: The closure called on every timer tick.
    ///   - onExpiration: The closure called on timer expiration.
    internal init(
        expirationTimeout: TimeInterval,
        onTick: @escaping (TimeInterval) -> Void,
        onExpiration: @escaping () -> Void
    ) {
        self.expirationTimeout = expirationTimeout
        self.timeLeft = expirationTimeout
        self.onTick = onTick
        self.onExpiration = onExpiration
    }
    
    internal func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard timer.isValid else { return }
            self?.onTimerTick()
        }
        
        // Notify immediately
        notify()
    }
    
    internal func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func onTimerTick() {
        defer { notify() }
        
        timeLeft -= 1
        
        if timeLeft <= 0 {
            stopTimer()
        }
    }
    
    private func notify() {
        if timeLeft > 0 {
            onTick(timeLeft)
        } else {
            onExpiration()
        }
    }
}
