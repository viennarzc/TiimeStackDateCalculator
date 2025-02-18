//
//  AllDatesMainView.swift
//  TimeStackDateCalculator
//
//  Created by Viennarz Curtiz on 2/17/25.
//

import SwiftUI

struct DatePeriodItemModel: Identifiable {
    let id: UUID = UUID()
    let date: Date
    let relativeDate: Date
    let label: String
}

struct AllDatesMainView: View {
    @State private var date: Date = Date()
    @State private var isPresentingAddIntervalSheet: Bool = false

    @State private var dates: [DatePeriodItemModel] = [
        .init(date: Date.distantFuture, relativeDate: Date.now, label: ""),
        .init(date: Date.now, relativeDate: Date.now, label: ""),
        .init(date: Date().sevenDaysFromNow, relativeDate: Date.now, label: ""),
    ]

    @ViewBuilder
    fileprivate func buildPeriodView(date: Date, relativeTo anchorDate: Date = Date.now) -> some View {
        GroupBox {
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.title.bold())
                .frame(minHeight: 70)

        } label: {
            Text(date.timeIntervalDescription(relativeTo: anchorDate).capitalized)
                .foregroundStyle(.secondary)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ScrollView {
                Spacer(minLength: 90)
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 180, maximum: 300))], pinnedViews: [.sectionHeaders]
                ) {
                    Section {
                        buildPeriodView(date: Date.now)
                        buildPeriodView(date: Date.now.oneYearAgo)
                        buildPeriodView(date: Date.now.oneYearFromNow)
                        buildPeriodView(date: Date.now.sevenDaysAgo)
                        buildPeriodView(date: Date.now.sevenDaysFromNow)
                        buildPeriodView(date: Date.now.threeMonthsAgo)
                        buildPeriodView(date: Date.now.threeMonthsFromNow)

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

                    Divider()

                    Spacer(minLength: 32)

                    Section {
                        GroupBox {
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
                        }

                        ForEach(dates) { date in
                            buildPeriodView(
                                date: date.date,
                                relativeTo: date.relativeDate
                            )
                        }

                    } header: {
                        VStack {
                            
                            Label("From: **\(date.formatted(date: .long, time: .omitted))**", systemImage: "calendar.badge.clock")
                                .symbolRenderingMode(.hierarchical)
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            GroupBox {
                                DatePicker(
                                    "Select a date",
                                    selection: $date.animation(.spring),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(CompactDatePickerStyle())
                                .onChange(of: date) {
                                    _,
                                    newValue in
                                    debugPrint(newValue)
                                    withAnimation {
                                        dates = [
                                            .init(
                                                date: newValue.oneYearFromNow,
                                                relativeDate: newValue,
                                                label: ""
                                            ),
                                            .init(
                                                date: newValue.oneYearAgo, relativeDate: newValue,
                                                label: ""
                                            ),
                                            .init(
                                                date: newValue.sevenDaysFromNow,
                                                relativeDate: newValue,
                                                label: ""
                                            ),
                                            .init(
                                                date: newValue.threeMonthsAgo, relativeDate: newValue,
                                                label: ""
                                            ),
                                            .init(
                                                date: newValue.sevenDaysAgo, relativeDate: newValue,
                                                label: ""
                                            ),
                                            .init(
                                                date: newValue.threeMonthsFromNow, relativeDate: newValue,
                                                label: ""
                                            ),
                                        ]
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                            .backgroundStyle(.quaternary)
                        }
                        .padding(.top, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                        )
                        .padding([.horizontal])
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $isPresentingAddIntervalSheet) {
            AddIntervalView()
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    AllDatesMainView()
}
