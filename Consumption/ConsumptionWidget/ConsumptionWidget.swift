//
//  ConsumptionWidget.swift
//  ConsumptionWidget
//
//  Created by Morris-Stiff R O (FCES) on 10/02/2025.
//

import WidgetKit
import SwiftUI

// Provider struct: This defines how the widget gets its data and updates.
struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry

    // Placeholder is used to show a preview of the widget in Widget Gallery
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dailyCalories: 0, dailyWater: 0.0)
    }

    // Snapshot generates a specific instance of widget for preview
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        // Retrieve real data or placeholder data for preview purposes
        let sharedDefaults = UserDefaults(suiteName: "group.usw.rms.Consumption")
        let dailyCalories = sharedDefaults?.integer(forKey: "dailyCalories") ?? 0
        let dailyWater = sharedDefaults?.double(forKey: "dailyWater") ?? 0.0

        let entry = SimpleEntry(date: Date(), dailyCalories: dailyCalories, dailyWater: dailyWater)
        completion(entry)
    }

    // Timeline generates a series of data entries, updating at regular intervals.
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let sharedDefaults = UserDefaults(suiteName: "group.usw.rms.Consumption")

        let dailyCalories = sharedDefaults?.integer(forKey: "dailyCalories") ?? 0
        let dailyWater = sharedDefaults?.double(forKey: "dailyWater") ?? 0.0

        print("Widget Fetching Calories: \(dailyCalories), Water: \(dailyWater)")

        let currentDate = Date()
        var entries: [SimpleEntry] = []

        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, dailyCalories: dailyCalories, dailyWater: dailyWater)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Example Widget")]
    }
}

// SimpleEntry struct: This represents a piece of data that will be shown in the widget
struct SimpleEntry: TimelineEntry {
    let date: Date
    let dailyCalories: Int
    let dailyWater: Double
}

// The widget view content that will display the progress of daily calories and water intake
struct ConsumptionWidgetEntryView : View {
    var entry: Provider.Entry

    // Calculate progress of calories and water
    var calorieProgress: Double {
        min(Double(entry.dailyCalories) / 2000.0, 1.0)
    }

    var waterProgress: Double {
        min(entry.dailyWater / 2.0, 1.0) // Assuming 2L as a goal for water
    }

    var body: some View {
        VStack {
            HStack {
                VStack {
                    // Calorie Progress Ring
                    ProgressView(value: calorieProgress, total: 1.0)
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .frame(width: 50, height: 50)
                        .overlay(Text("\(entry.dailyCalories)/2000 kcal")
                                    .font(.caption)
                                    .foregroundColor(.red))

                    // Water Progress Ring
                    ProgressView(value: waterProgress, total: 1.0)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .frame(width: 50, height: 50)
                        .overlay(Text("\(entry.dailyWater, specifier: "%.1f")/2.0 L")
                                    .font(.caption)
                                    .foregroundColor(.blue))
                }
                .padding()
            }
        }
    }
}

// The main widget configuration
@main
struct ConsumptionWidget: Widget {
    let kind: String = "ConsumptionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ConsumptionWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Consumption Widget")
        .description("Track your daily calorie and water intake.")
    }
}

#Preview(as: .accessoryRectangular) {
    ConsumptionWidget()
} timeline: {
    SimpleEntry(date: .now, dailyCalories: 1000, dailyWater: 1.5)
}
