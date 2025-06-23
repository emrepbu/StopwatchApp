//
//  StopwatchWidgetBundle.swift
//  StopwatchWidget
//
//  Created by emre argana on 23.06.2025.
//

import WidgetKit
import SwiftUI

@main
struct StopwatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Include both regular widgets and Live Activities
        if #available(iOS 16.1, *) {
            StopwatchWidgetLiveActivity()
        }
        // Add other widgets here if needed
    }
}
