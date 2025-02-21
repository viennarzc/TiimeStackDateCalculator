//
//  TimeIntervalContainerView.swift
//  TimeStackDateCalculator
//
//  Created by Viennarz Curtiz on 2/21/25.
//
import SwiftUI
import Foundation

struct TimeIntervalContainerView: View {
    let baseDate: Date
    /// This is the date with added or subtracted value
    let relativeDate: Date
    
    var body: some View {
        GroupBox {
            Text(relativeDate.formatted(date: .abbreviated, time: .omitted))
                .font(.title.bold())
                .frame(minHeight: 70)
            
        } label: {
            Text(relativeDate.timeIntervalDescription(relativeTo: baseDate).capitalized)
                .foregroundStyle(.secondary)
        }
        
     
    }
}

#Preview {
    VStack {
        TimeIntervalContainerView(
            baseDate: Date.now,
            relativeDate: Date.now.sevenDaysAgo
        )
        
    }
}

