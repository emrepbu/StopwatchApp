//
//  StopwatchWidgetLiveActivity.swift
//  StopwatchWidget
//
//  Created by emre argana on 23.06.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct StopwatchWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StopwatchAttributes.self) { context in
            // Lock Screen Live Activity View
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(.black)
                .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "stopwatch")
                            .foregroundColor(.white)
                            .font(.title2)
                        Text("Stopwatch")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.leading)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        if context.state.isRunning {
                            Text("RUNNING")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("PAUSED")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        // Gerçek zamanlı lap sayısı
                        Text("Laps: \(context.state.lapCount)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Spacer()
                        
                        // Gerçek zamanlı süre gösterimi
                        TimelineView(.periodic(from: Date(), by: 0.1)) { timeline in
                            Text(getDisplayTime(for: context.state, at: timeline.date))
                                .font(.system(size: 28, weight: .medium, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 8)
                }
                
            } compactLeading: {
                // Compact Leading - Gerçek zamanlı
                TimelineView(.periodic(from: Date(), by: 0.1)) { timeline in
                    HStack(spacing: 4) {
                        Image(systemName: "stopwatch.fill")
                            .foregroundColor(context.state.isRunning ? .green : .orange)
                            .font(.caption)
                        
                        Text(String(getDisplayTime(for: context.state, at: timeline.date).prefix(5)))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                
            } compactTrailing: {
                // Compact Trailing - Gerçek zamanlı lap sayısı
                Text("\(context.state.lapCount)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.3))
                    )
                
            } minimal: {
                // Minimal View
                Image(systemName: "stopwatch.fill")
                    .foregroundColor(context.state.isRunning ? .green : .orange)
                    .font(.caption)
            }
            .keylineTint(Color.blue)
            .widgetURL(URL(string: "stopwatch://open"))
        }
    }
    
    // Helper function for real-time display
    private func getDisplayTime(for state: StopwatchAttributes.ContentState, at date: Date) -> String {
        var totalTime = state.totalElapsedTime
        if state.isRunning, let startTime = state.startTime {
            totalTime += date.timeIntervalSince(startTime)
        }
        
        let minutes = Int(totalTime) / 60
        let seconds = Int(totalTime) % 60
        let milliseconds = Int((totalTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<StopwatchAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "stopwatch.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text("Stopwatch")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(context.state.isRunning ? .green : .orange)
                        .frame(width: 8, height: 8)
                    
                    Text(context.state.isRunning ? "RUNNING" : "PAUSED")
                        .font(.caption)
                        .foregroundColor(context.state.isRunning ? .green : .orange)
                }
            }
            
            // Gerçek zamanlı süre gösterimi
            TimelineView(.periodic(from: Date(), by: 0.1)) { timeline in
                HStack {
                    Text(getDisplayTime(for: context.state, at: timeline.date))
                        .font(.system(size: 32, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if context.state.lapCount > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("LAPS")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            Text("\(context.state.lapCount)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            
            if context.state.isRunning {
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 0.5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private func getDisplayTime(for state: StopwatchAttributes.ContentState, at date: Date) -> String {
        var totalTime = state.totalElapsedTime
        if state.isRunning, let startTime = state.startTime {
            totalTime += date.timeIntervalSince(startTime)
        }
        
        let minutes = Int(totalTime) / 60
        let seconds = Int(totalTime) % 60
        //        let milliseconds = Int((totalTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
