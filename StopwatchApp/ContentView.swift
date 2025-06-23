//
//  ContentView.swift
//  StopwatchApp
//
//  Created by emre argana on 23.06.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StopwatchViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Time Display
            Text(viewModel.displayTime)
                .font(.system(size: 60, weight: .thin, design: .monospaced))
                .foregroundColor(.white)
            
            // Lap Times List
            if !viewModel.lapTimes.isEmpty {
                List(Array(viewModel.lapTimes.enumerated().reversed()), id: \.offset) { index, lapTime in
                    HStack {
                        Text("Lap \(viewModel.lapTimes.count - index)")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(lapTime)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.clear)
                }
                .frame(maxHeight: 200)
                .listStyle(PlainListStyle())
            }
            
            Spacer()
            
            // Control Buttons
            HStack(spacing: 60) {
                // Left Button (Lap/Reset)
                Button(action: {
                    if viewModel.isRunning {
                        viewModel.recordLap()
                    } else {
                        viewModel.resetStopwatch()
                    }
                }) {
                    Text(viewModel.isRunning ? "Lap" : "Reset")
                        .font(.title2)
                        .foregroundColor(viewModel.isRunning ? .white : .gray)
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                        )
                }
                .disabled(!viewModel.isRunning && viewModel.displayTime == "00:00.00")
                
                // Right Button (Start/Stop)
                Button(action: {
                    if viewModel.isRunning {
                        viewModel.pauseStopwatch()
                    } else {
                        viewModel.startStopwatch()
                    }
                }) {
                    Text(viewModel.isRunning ? "Stop" : "Start")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(viewModel.isRunning ? Color.red : Color.green)
                                .overlay(
                                    Circle()
                                        .stroke(viewModel.isRunning ? Color.red : Color.green, lineWidth: 2)
                                )
                        )
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}
