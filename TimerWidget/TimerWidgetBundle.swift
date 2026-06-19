//
//  TimerWidgetBundle.swift
//  TimerWidget
//
//  Created by Yuki Suzuki on 6/1/26.
//

import WidgetKit
import SwiftUI

@main
struct TimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerWidget()
        TimerWidgetControl()
        TimerWidgetLiveActivity()
    }
}
