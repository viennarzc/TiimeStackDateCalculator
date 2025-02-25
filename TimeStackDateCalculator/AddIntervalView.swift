//
//  AddIntervalView.swift
//  TimeStackDateCalculator
//
//  Created by Viennarz Curtiz on 2/18/25.
//

import SwiftUI

struct AddIntervalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    enum Component: CaseIterable {
        case year
        case month
        case day

        var displayTitle: String {
            switch self {
            case .year:
                return "Year"
            case .month:
                return "Month"
            case .day:
                return "Day"
            }
        }
    }

    enum Chronology: CaseIterable {
        case past
        case future

        var displayTite: String {
            switch self {
            case .past:
                return "Past"
            case .future:
                return "Future"
            }
        }
        
        var displayText2: String {
            switch self {
            case .past: return "before"
                
            case .future: return "after"
            }
        }
    }

    @State private var component: Component = .day
    @State private var value: Int = 1
    @State private var chronology: Chronology = .past

    @State private var date: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack {
                        HStack(spacing: 0) {
                            IntegerTextField(
                                value: $value,
                                placeholder: "Number of \(component.displayTitle)s"
                            )
                            .font(.title2.bold())
                            .onChange(of: value) { _, newValue in
                                debugPrint("New \(newValue)")
                            }
                            
                            Picker(selection: $component) {
                                ForEach(Component.allCases, id: \.self) { item in
                                    Text(item.displayTitle).tag(item)
                                }
                                
                            } label: {
                                Text("")
                            }
                            .pickerStyle(MenuPickerStyle())
                            .labelsVisibility(.hidden)
                            
                            Picker(selection: $chronology) {
                                ForEach(Chronology.allCases, id: \.self) { item in
                                    Text(item.displayTite).tag(item)
                                }
                            } label: {
                                Text("Time Period")
                            }
                            .labelsVisibility(.hidden)
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    
                    VStack {
                        
                        Text("Preview")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.secondary)
                        
                        Text(
                            "**^[\(value) \(component.displayTitle.lowercased())](inflect: true) \(chronology.displayText2.lowercased())** \(Date.now.formatted(date: .long, time: .omitted))"
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Section {
                    Button {
                        
                        let newItem: TimeIntervalEntity = TimeIntervalEntity(context: viewContext)
                        
                        newItem.id = UUID()
                        newItem.timestamp = Date.now
                        newItem.label = "Custom"
                        newItem.intervalUnit = component.displayTitle
                            .lowercased()
                        newItem.intervalValue = Int16(value)
                        
                        do {
                            try viewContext.save()
                            debugPrint("Successfully saved new item")
                            dismiss.callAsFunction()

                        } catch let error {
                            debugPrint("Error encountered when adding a new item", error.localizedDescription)
                        }
                        
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("Add Custom Interval")
            .safeAreaPadding(.top, 120)
        }
    }
}

#Preview {
    AddIntervalView()
}

struct IntegerTextField: View {
    @Binding var value: Int
    @StateObject private var fieldValue = IntegerTextFieldValue()

    var placeholder = ""

    var body: some View {
        TextField(placeholder, text: $fieldValue.value)
            .keyboardType(.numberPad)
            .onChange(of: fieldValue.value) { newValue in
                value = Int(newValue) ?? 1
            }
            .onAppear {
                fieldValue.value = "\(value)"
            }
    }
}

private class IntegerTextFieldValue: ObservableObject {
    @Published var value = "" {
        didSet {
            let numbersOnly = value.filter { $0.isNumber }
            if value != numbersOnly {
                value = numbersOnly
            }
        }
    }
}


extension TimeIntervalEntity {
    func toDatePeriodItemModel(withBase newBaseDate: Date = Date.now) -> DatePeriodItemModel {
        // Calculate the relative date based on intervalUnit and intervalValue
        let relativeDate: Date
        
        switch intervalUnit {
        case "year":
            relativeDate = Calendar.current
                .date(
                    byAdding: .year,
                    value: Int(intervalValue),
                    to: baseDate ?? newBaseDate
                ) ?? Date.now
        case "month":
            relativeDate = Calendar.current
                .date(
                    byAdding: .month,
                    value: Int(intervalValue),
                    to: baseDate ?? newBaseDate
                ) ?? Date.now
        case "day":
            relativeDate = Calendar.current
                .date(
                    byAdding: .day,
                    value: Int(intervalValue),
                    to: baseDate ?? newBaseDate
                ) ?? Date.now
        default:
            // Default to the base date if intervalUnit is not recognized
            relativeDate = Date.now
        }
        
        return DatePeriodItemModel(
            relativeDate: relativeDate,
            baseDate: baseDate ?? newBaseDate,
            label: label ?? "Label",
            isCustom: true,
            item: self
        )
    }
}
