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

                Section {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 180, maximum: 300))]
                    ) {
                        buildPeriodView(date: Date.now)
                        buildPeriodView(date: Date.now.oneYearAgo)
                        buildPeriodView(date: Date.now.oneYearFromNow)
                        buildPeriodView(date: Date.now.sevenDaysAgo)
                        buildPeriodView(date: Date.now.sevenDaysFromNow)
                        buildPeriodView(date: Date.now.threeMonthsAgo)
                        buildPeriodView(date: Date.now.threeMonthsFromNow)
                    }
                    .padding(.horizontal)

                } header: {
                    Text(
                        "Today: **\(Date.now.formatted(date: .long, time: .omitted))**"
                    )
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }

                Divider()

                Spacer(minLength: 32)

                Section {
//                    GroupBox {
//                        Button(action: { }) {
//                            Label {
//                                Text("Add Custom Interval")
//                            } icon: {
//
//                                Image(systemName: "plus")
//                                    .font(.system(size: 24))
//                            }
//
//                        }
//                    }

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 180, maximum: 300))]
                    ) {
                        ForEach(dates) { date in
                            buildPeriodView(
                                date: date.date,
                                relativeTo: date.relativeDate
                            )
                        }
                    }
                    .padding(.horizontal)

                } header: {
                    Text("From: **\(date.formatted(date: .long, time: .omitted))**")
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
                    .backgroundStyle(.quaternary)
                }
            }
        }
    }
}

#Preview {
    AllDatesMainView()
}

