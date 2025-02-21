//
//  AllDatesMainView.swift
//  TimeStackDateCalculator
//
//  Created by Viennarz Curtiz on 2/17/25.
//

import SwiftUI

struct DatePeriodItemModel: Identifiable {
    internal init(
        relativeDate: Date,
        baseDate: Date,
        label: String,
        isCustom: Bool = false,
        item: TimeIntervalEntity? = nil
    ) {
        self.relativeDate = relativeDate
        self.baseDate = baseDate
        self.label = label
        self.isCustom = isCustom
        timeIntervalEntity = item
    }

    let id: UUID = UUID()
    let relativeDate: Date //the interval
    let baseDate: Date //the selected
    let label: String
    let isCustom: Bool
    let timeIntervalEntity: TimeIntervalEntity?
}

struct AllDatesMainView: View {
    enum Content: CaseIterable, Identifiable {
        case today
        case custom

        var id: Self {
            self
        }

        var displayText: String {
            switch self {
            case .today:
                return "Today"
            case .custom:
                return "Custom"
            }
        }
    }

    @Environment(\.managedObjectContext) private var viewContext

    private let coreDataManager: CoreDataManager = CoreDataManager.shared

    @State private var date: Date = Date()
    @State private var isPresentingAddIntervalSheet: Bool = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TimeIntervalEntity.timestamp, ascending: false)],
        animation: .default
    )
    private var customTimeIntervalItems: FetchedResults<TimeIntervalEntity>

    @State private var content: Content = .today

    @State private var dates: [DatePeriodItemModel] = [
        
            .init(
                relativeDate: Date.now.oneYearFromNow,
                baseDate: Date.now,
                label: ""
            ),
            .init(
                relativeDate: Date.now.oneYearAgo,
                baseDate: Date.now.oneYearAgo,
                label: ""
            ),
            .init(
                relativeDate: Date.now.sevenDaysFromNow,
                baseDate: Date.now,
                label: ""
            ),
            .init(
                relativeDate: Date.now.threeMonthsAgo, baseDate: Date.now,
                label: ""
            ),
            .init(
                relativeDate: Date.now.sevenDaysAgo, baseDate: Date.now,
                label: ""
            ),
            .init(
                relativeDate: Date.now.threeMonthsFromNow, baseDate: Date.now,
                label: ""
            )
    ]

    @ViewBuilder
    fileprivate func buildPeriodView(item: TimeIntervalEntity? = nil, date: Date = Date.now, relativeTo anchorDate: Date, canShowContextMenu: Bool = false) -> some View {
        TimeIntervalContainerView(baseDate: date, relativeDate: anchorDate)
            .transition(
                .asymmetric(insertion: .scale, removal: .opacity)
            )
            .modifier(ConditionalContextMenu(isEnabled: canShowContextMenu) {
                Button {
                    // Action
                    if let item = item {
                        deleteItem(item: item)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            })
            .overlay(alignment: .topTrailing, content: {
                if canShowContextMenu {
                    Circle().fill(Color.blue.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .offset(x: -4, y: 4)
                }
            })
            .overlay {
                if canShowContextMenu {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                }
            }
    }

    @ViewBuilder
    var todayContent: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 180, maximum: 300))], pinnedViews: [.sectionHeaders]
            ) {
                Section {
                    buildPeriodView(date: Date.now, relativeTo: Date.now)
                    buildPeriodView(relativeTo: Date.now.oneYearAgo)
                    buildPeriodView(relativeTo: Date.now.oneYearFromNow)
                    buildPeriodView(relativeTo: Date.now.sevenDaysAgo)
                    buildPeriodView(relativeTo: Date.now.sevenDaysFromNow)
                    buildPeriodView(relativeTo: Date.now.threeMonthsAgo)
                    buildPeriodView(relativeTo: Date.now.threeMonthsFromNow)

                } header: {
                    Label("Today: **\(Date.now.formatted(date: .long, time: .omitted))**", systemImage: "calendar.badge.checkmark")
                        .symbolRenderingMode(.hierarchical)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical)
                        .background(
                            Capsule().fill(Color(.systemBackground))
                        )
                        .padding(.horizontal)
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var customContent: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 180, maximum: 300))], pinnedViews: [.sectionHeaders]
            ) {
                Section {
                    Button(action: {
                        isPresentingAddIntervalSheet = true
                    }) {
                        Label {
                            Text("Add Custom Interval")
                                .frame(
                                    maxWidth: 150, minHeight: 70,
                                    maxHeight: 150)
                                .fontWeight(.bold)
                        } icon: {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                        }
                    }
                    .padding()

                    ForEach(customTimeIntervalItems) { item in
                        buildPeriodView(
                            item: item,
                            date: self.date,
                            relativeTo: convert(
                                unit: item.intervalUnit ?? "",
                                with: item.intervalValue,
                                of: self.date
                            ),
                            canShowContextMenu: true
                        )
                    }

                    ForEach(dates) { date in
                        buildPeriodView(
                            item: date.timeIntervalEntity,
                            date: date.baseDate,
                            relativeTo: date.relativeDate,
                            canShowContextMenu: date.isCustom
                        )
                    }

                } header: {
                    HStack {
                        Label("From: ", systemImage: "calendar.badge.clock")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)

                        DatePicker(
                            "From:",
                            selection: $date.animation(.spring),
                            displayedComponents: .date
                        )
                        .datePickerStyle(CompactDatePickerStyle())
                        .frame(width: 100)
                        .padding(.trailing)
                    }
                    .frame(height: 50)
                    .padding(.horizontal)
                    .onChange(of: date) {
                        _,
                            newValue in
                        debugPrint(newValue)
                        withAnimation {
                            dates = [
                                .init(
                                    relativeDate: newValue.oneYearFromNow,
                                    baseDate: newValue,
                                    label: ""
                                ),
                                .init(
                                    relativeDate: newValue.oneYearAgo,
                                    baseDate: newValue.oneYearAgo,
                                    label: ""
                                ),
                                .init(
                                    relativeDate: newValue.sevenDaysFromNow,
                                    baseDate: newValue,
                                    label: ""
                                ),
                                .init(
                                    relativeDate: newValue.threeMonthsAgo, baseDate: newValue,
                                    label: ""
                                ),
                                .init(
                                    relativeDate: newValue.sevenDaysAgo, baseDate: newValue,
                                    label: ""
                                ),
                                .init(
                                    relativeDate: newValue.threeMonthsFromNow, baseDate: newValue,
                                    label: ""
                                ),
                            ]
                        }
                    }
                    .background(
                        Capsule().fill(Color(.systemBackground))
                    )
                    .padding([.horizontal])
                }
            }
            .padding(.horizontal)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Picker(
                "Content Selection",
                selection: $content.animation(.easeInOut)
            ) {
                ForEach(Content.allCases) { content in
                    Text(content.displayText)
                        .tag(content.id)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            TabView(selection: $content.animation(.easeInOut)) {
                todayContent
                    .tag(Content.today)

                customContent
                    .tag(Content.custom)
            }
            .tabViewStyle(PageTabViewStyle())

            Spacer()
        }
        .sheet(isPresented: $isPresentingAddIntervalSheet) {
            AddIntervalView()
                .environment(\.managedObjectContext, viewContext)
                .presentationDetents([.medium, .large])
        }
    }

    func deleteItem(item: TimeIntervalEntity) {
        viewContext.delete(item)

        saveContext()
    }

    func saveContext() {
        do {
            try viewContext.save()

        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func convert(unit intervalUnit: String, with intervalValue: Int16, of baseDate: Date) -> Date {
        let relativeDate: Date
        
        switch intervalUnit {
        case "year":
            relativeDate = Calendar.current
                .date(
                    byAdding: .year,
                    value: Int(intervalValue),
                    to: baseDate
                ) ?? Date.now
        case "month":
            relativeDate = Calendar.current
                .date(
                    byAdding: .month,
                    value: Int(intervalValue),
                    to: baseDate
                ) ?? Date.now
        case "day":
            relativeDate = Calendar.current
                .date(
                    byAdding: .day,
                    value: Int(intervalValue),
                    to: baseDate
                ) ?? Date.now
        default:
            // Default to the base date if intervalUnit is not recognized
            relativeDate = Date.now
        }
        
        return relativeDate
    }
}

#Preview {
    AllDatesMainView()
}

// Custom view modifier to conditionally apply context menu
struct ConditionalContextMenu<MenuContent: View>: ViewModifier {
    let isEnabled: Bool
    let menuContent: () -> MenuContent

    func body(content: Content) -> some View {
        if isEnabled {
            content.contextMenu {
                menuContent()
            }
        } else {
            content
        }
    }
}

// Extension to make it cleaner to use
extension View {
    func conditionalContextMenu<MenuContent: View>(isEnabled: Bool, @ViewBuilder menuContent: @escaping () -> MenuContent) -> some View {
        modifier(ConditionalContextMenu(isEnabled: isEnabled, menuContent: menuContent))
    }
}
