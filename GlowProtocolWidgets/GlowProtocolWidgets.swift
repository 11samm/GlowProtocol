//
//  GlowProtocolWidgets.swift
//  GlowProtocolWidgets
//
//  Widget bundle entry point. GlowTimerLiveActivity is the Live Activity widget
//  for the workout timer. Home-screen widgets can be added here in future.
//

import WidgetKit
import SwiftUI

@main
struct GlowProtocolWidgetBundle: WidgetBundle {
    var body: some Widget {
        GlowTimerLiveActivity()
    }
}
