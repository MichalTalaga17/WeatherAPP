//
//  WeatherAPPwidgetsLiveActivity.swift
//  WeatherAPPwidgets
//
//  Created by Michał Talaga on 22/08/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WeatherAPPwidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct WeatherAPPwidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WeatherAPPwidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension WeatherAPPwidgetsAttributes {
    fileprivate static var preview: WeatherAPPwidgetsAttributes {
        WeatherAPPwidgetsAttributes(name: "World")
    }
}

extension WeatherAPPwidgetsAttributes.ContentState {
    fileprivate static var smiley: WeatherAPPwidgetsAttributes.ContentState {
        WeatherAPPwidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WeatherAPPwidgetsAttributes.ContentState {
         WeatherAPPwidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: WeatherAPPwidgetsAttributes.preview) {
   WeatherAPPwidgetsLiveActivity()
} contentStates: {
    WeatherAPPwidgetsAttributes.ContentState.smiley
    WeatherAPPwidgetsAttributes.ContentState.starEyes
}
