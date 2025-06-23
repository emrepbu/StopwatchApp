//
//  StopwatchViewModel.swift
//  StopwatchApp
//
//  Created by emre argana on 23.06.2025.
//

import Foundation
import SwiftUI
import ActivityKit
import Combine

@MainActor
class StopwatchViewModel: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var displayTime = "00:00.00"
    @Published private(set) var lapTimes: [String] = []
    
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    private var totalElapsedTime: TimeInterval = 0
    private var timer: Timer?
    private var currentActivity: Activity<StopwatchAttributes>?
    private var updateTimer: Timer?
    
    // MARK: - Stopwatch Controls
    
    func startStopwatch() {
        guard !isRunning else { return }
        
        isRunning = true
        startTime = Date()
        
        // Start local timer for UI updates
        startTimer()
        
        // Start Live Activity
        startLiveActivity()
        
        // Start update timer for Live Activity
        startUpdateTimer()
    }
    
    func pauseStopwatch() {
        guard isRunning else { return }
        
        isRunning = false
        if let startTime = startTime {
            totalElapsedTime += Date().timeIntervalSince(startTime)
        }
        
        // Stop timers
        stopTimer()
        stopUpdateTimer()
        
        // Final update for Live Activity
        updateLiveActivity(immediate: true)
    }
    
    func resetStopwatch() {
        isRunning = false
        startTime = nil
        pausedTime = 0
        totalElapsedTime = 0
        displayTime = "00:00.00"
        lapTimes.removeAll()
        
        stopTimer()
        stopUpdateTimer()
        endLiveActivity()
    }
    
    func recordLap() {
        guard isRunning else { return }
        
        let currentTime = getCurrentTime()
        lapTimes.append(formatTime(currentTime))
        
        // Update Live Activity immediately when lap is recorded
        updateLiveActivity(immediate: true)
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateDisplayTime()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Separate timer specifically for Live Activity updates
    private func startUpdateTimer() {
        // Update Live Activity every 0.1 seconds for smooth updates
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateLiveActivity(immediate: false)
            }
        }
    }
    
    private func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updateDisplayTime() {
        displayTime = formatTime(getCurrentTime())
    }
    
    private func getCurrentTime() -> TimeInterval {
        let current = totalElapsedTime
        if let startTime = startTime, isRunning {
            return current + Date().timeIntervalSince(startTime)
        }
        return current
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    // MARK: - Live Activity Management
    
    private func startLiveActivity() {
        // Check if Live Activities are enabled
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        let attributes = StopwatchAttributes(
            stopwatchName: "Stopwatch",
            activityId: UUID().uuidString
        )
        
        let contentState = StopwatchAttributes.ContentState(
            isRunning: isRunning,
            startTime: startTime,
            pausedTime: pausedTime,
            totalElapsedTime: totalElapsedTime,
            lapCount: lapTimes.count,
            currentLapStartTime: startTime
        )
        
        let activityContent = ActivityContent(
            state: contentState,
            staleDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date()),
            relevanceScore: 100.0 // High priority
        )
        
        do {
            let activity = try Activity<StopwatchAttributes>.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
            currentActivity = activity
            print("Started Live Activity: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    private func updateLiveActivity(immediate: Bool) {
        guard let activity = currentActivity else { return }
        
        let contentState = StopwatchAttributes.ContentState(
            isRunning: isRunning,
            startTime: startTime,
            pausedTime: pausedTime,
            totalElapsedTime: totalElapsedTime,
            lapCount: lapTimes.count,
            currentLapStartTime: startTime
        )
        
        let activityContent = ActivityContent(
            state: contentState,
            staleDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date()),
            relevanceScore: immediate ? 100.0 : 50.0
        )
        
        Task {
            do {
                // Use immediate update policy for critical updates
                if immediate {
                    await activity.update(activityContent, alertConfiguration: nil)
                } else {
                    await activity.update(activityContent)
                }
            } catch {
                print("Failed to update Live Activity: \(error)")
            }
        }
    }
    
    private func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        let finalState = StopwatchAttributes.ContentState(
            isRunning: false,
            startTime: nil,
            pausedTime: 0,
            totalElapsedTime: 0,
            lapCount: 0,
            currentLapStartTime: nil
        )
        
        let finalContent = ActivityContent(
            state: finalState,
            staleDate: nil
        )
        
        Task {
            await activity.end(finalContent, dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
}
