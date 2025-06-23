//
//  StopwatchAttributes.swift
//  StopwatchApp
//
//  Created by emre argana on 23.06.2025.
//

import Foundation
import ActivityKit

struct StopwatchAttributes: ActivityAttributes {
    public typealias StopwatchStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var isRunning: Bool
        var startTime: Date?
        var pausedTime: TimeInterval
        var totalElapsedTime: TimeInterval
        var lapCount: Int
        var currentLapStartTime: Date?
        
        // Gerçek zamanlı hesaplama için
        var currentTime: TimeInterval {
            if isRunning, let startTime = startTime {
                return totalElapsedTime + Date().timeIntervalSince(startTime)
            }
            return totalElapsedTime
        }
        
        var displayTime: String {
            formatTime(currentTime)
        }
        
        private func formatTime(_ timeInterval: TimeInterval) -> String {
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 100)
            return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
        }
    }
    
    var stopwatchName: String
    var activityId: String
}
