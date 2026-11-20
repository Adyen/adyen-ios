//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A class for handling expiration timers
@MainActor
internal final class ExpirationTimer {
    
    private let expirationTimeout: TimeInterval
    
    private var timeLeft: TimeInterval
    
    private var timer: Timer?
    
    private let onTick: @MainActor (TimeInterval) -> Void
    
    private let onExpiration: @MainActor () -> Void
    
    /// Initializes `ExpirationTimer` object
    /// - Parameters:
    ///   - expirationTimeout: The time interval after which timer expires.
    ///   - tickInterval: The interval with which the timer ticks.
    ///   - onTick: The closure called on every timer tick.
    ///   - onExpiration: The closure called on timer expiration.
    internal init(
        expirationTimeout: TimeInterval,
        onTick: @escaping @MainActor (TimeInterval) -> Void,
        onExpiration: @escaping @MainActor () -> Void
    ) {
        self.expirationTimeout = expirationTimeout
        self.timeLeft = expirationTimeout
        self.onTick = onTick
        self.onExpiration = onExpiration
    }
    
    internal func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // The timer is scheduled on the current run loop, so hop to the main actor.
            Task { @MainActor [weak self] in
                guard let self, self.timer?.isValid == true else { return }
                self.onTimerTick()
            }
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
