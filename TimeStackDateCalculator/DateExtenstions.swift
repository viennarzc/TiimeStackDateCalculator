//
//  File.swift
//  TimeStackDateCalculator
//
//  Created by Viennarz Curtiz on 2/18/25.
//


import Foundation

extension Date {
    // MARK: - Fixed time intervals

    /// Returns a Date representing 7 days ago from the current date
    var sevenDaysAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: self)!
    }

    /// Returns a Date representing 7 days from now
    var sevenDaysFromNow: Date {
        return Calendar.current.date(byAdding: .day, value: 7, to: self)!
    }

    /// Returns a Date representing 1 year ago from the current date
    var oneYearAgo: Date {
        return Calendar.current.date(byAdding: .year, value: -1, to: self)!
    }

    /// Returns a Date representing 1 year from now
    var oneYearFromNow: Date {
        return Calendar.current.date(byAdding: .year, value: 1, to: self)!
    }

    /// Returns a Date representing 3 months ago from the current date
    var threeMonthsAgo: Date {
        return Calendar.current.date(byAdding: .month, value: -3, to: self)!
    }

    /// Returns a Date representing 3 months from now
    var threeMonthsFromNow: Date {
        return Calendar.current.date(byAdding: .month, value: 3, to: self)!
    }

    // MARK: - Customizable time intervals

    /// Returns a Date by adding the specified number of days to the current date
    /// - Parameter days: Number of days to add (use negative values for past dates)
    /// - Returns: A new Date object
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    /// Returns a Date by adding the specified number of months to the current date
    /// - Parameter months: Number of months to add (use negative values for past dates)
    /// - Returns: A new Date object
    func adding(months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self)!
    }

    /// Returns a Date by adding the specified number of years to the current date
    /// - Parameter years: Number of years to add (use negative values for past dates)
    /// - Returns: A new Date object
    func adding(years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self)!
    }

    /// Returns a Date by adding multiple calendar components to the current date
    /// - Parameters:
    ///   - days: Number of days to add (optional)
    ///   - months: Number of months to add (optional)
    ///   - years: Number of years to add (optional)
    /// - Returns: A new Date object
    func adding(days: Int? = nil, months: Int? = nil, years: Int? = nil) -> Date {
        var dateComponents = DateComponents()
        if let days = days {
            dateComponents.day = days
        }
        if let months = months {
            dateComponents.month = months
        }
        if let years = years {
            dateComponents.year = years
        }
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
}

import Foundation

extension Date {
    // MARK: - String Descriptions

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }

    /// Returns a string representation of the date relative to now using natural language
    var relativeTimeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    func timeIntervalDescriptionRelateToSelf() -> String {
        let calendar = Calendar.current

        let normalizedSelf = startOfDay

        let components = calendar.dateComponents([.year, .month, .day], from: normalizedSelf)
        
        // Check years first
        if let year = components.year, year > 0 {
            return year == 1 ? "after a year" : "in \(year) years"
        }
        // Then check months if no years
        else if let month = components.month, month > 0 {
            return month == 1 ? "after a month" : "in \(month) months"
        }
        // Finally check days if no months or years
        else if let day = components.day, day > 0 {
            if day == 7 {
                return "after a week"
            } else {
                return "in \(day) days"
            }
        }
        
        return "Same day"
        
    }
    
    /// Returns a string description of time elapsed/remaining relative to another date
        /// - Parameter otherDate: The date to calculate the interval from
        /// - Returns: A string representing the time interval in natural language
        func timeIntervalDescription(relativeTo otherDate: Date) -> String {
            let calendar = Calendar.current
            
            // Use startOfDay for more consistent component calculations
            let normalizedOther = otherDate.startOfDay
            let normalizedSelf = startOfDay
            
            // Exact same instant
            if abs(timeIntervalSince(otherDate)) < 1.0 {
                return "same time"
            }
            
            if otherDate > self {
                // Self is before otherDate
                if calendar.isDate(self, inSameDayAs: otherDate) {
                    return "earlier that day"
                } else if calendar.isDate(self, equalTo: calendar.date(byAdding: .day, value: -1, to: otherDate)!, toGranularity: .day) {
                    return "the day before"
                } else {
                    let components = calendar.dateComponents([.day, .month, .year], from: normalizedSelf, to: normalizedOther)
                    
                    // Check years first
                    if let year = components.year, year > 0 {
                        return year == 1 ? "the year before" : "\(year) years before"
                    }
                    // Then check months if no years
                    else if let month = components.month, month > 0 {
                        return month == 1 ? "the month before" : "\(month) months before"
                    }
                    // Finally check days if no months or years
                    else if let day = components.day, day > 0 {
                        if day == 7 {
                            return "the week before"
                        } else {
                            return "\(day) days before"
                        }
                    }
                }
            } else {
                // Self is after otherDate
                if calendar.isDate(self, inSameDayAs: otherDate) {
                    return "later that day"
                } else if calendar.isDate(self, equalTo: calendar.date(byAdding: .day, value: 1, to: otherDate)!, toGranularity: .day) {
                    return "the day after"
                } else {
                    let components = calendar.dateComponents([.day, .month, .year], from: normalizedOther, to: normalizedSelf)
                    
                    // Check years first
                    if let year = components.year, year > 0 {
                        return year == 1 ? "the year after" : "\(year) years after"
                    }
                    // Then check months if no years
                    else if let month = components.month, month > 0 {
                        return month == 1 ? "the month after" : "\(month) months after"
                    }
                    // Finally check days if no months or years
                    else if let day = components.day, day > 0 {
                        if day == 7 {
                            return "the week after"
                        } else {
                            return "\(day) days after"
                        }
                    }
                }
            }
            
            return "same time"
        }
    
    

    /// Returns a string description of time elapsed/remaining from now
    var timeIntervalDescription: String {
        let calendar = Calendar.current
        let now = Date()

        // Use startOfDay for more consistent component calculations
        let normalizedNow = now.startOfDay
        let normalizedSelf = startOfDay

        // Exact same instant
        if abs(timeIntervalSince(now)) < 1.0 {
            return "now"
        }

        if now > self {
            // Date is in the past
            if calendar.isDateInToday(self) {
                return "earlier today"
            } else if calendar.isDateInYesterday(self) {
                return "yesterday"
            } else {
                let components = calendar.dateComponents([.day, .month, .year], from: normalizedSelf, to: normalizedNow)

                // Check years first
                if let year = components.year, year > 0 {
                    return year == 1 ? "last year" : "\(year) years ago"
                }
                // Then check months if no years
                else if let month = components.month, month > 0 {
                    return month == 1 ? "last month" : "\(month) months ago"
                }
                // Finally check days if no months or years
                else if let day = components.day, day > 0 {
                    if day == 7 {
                        return "last week"
                    } else {
                        return "\(day) days ago"
                    }
                }
            }
        } else {
            // Date is in the future
            if calendar.isDateInToday(self) {
                return "later today"
            } else if calendar.isDateInTomorrow(self) {
                return "tomorrow"
            } else {
                let components = calendar.dateComponents([.day, .month, .year], from: normalizedNow, to: normalizedSelf)

                // Check years first
                if let year = components.year, year > 0 {
                    return year == 1 ? "next year" : "in \(year) years"
                }
                // Then check months if no years
                else if let month = components.month, month > 0 {
                    return month == 1 ? "next month" : "in \(month) months"
                }
                // Finally check days if no months or years
                else if let day = components.day, day > 0 {
                    if day == 7 {
                        return "next week"
                    } else {
                        return "in \(day) days"
                    }
                }
            }
        }

        return "now"
    }

    /// Returns string descriptions for fixed intervals
    var sevenDaysAgoDescription: String {
        return "seven days ago"
    }

    var sevenDaysFromNowDescription: String {
        return "seven days from now"
    }

    var oneYearAgoDescription: String {
        return "one year ago"
    }

    var oneYearFromNowDescription: String {
        return "one year from now"
    }

    var threeMonthsAgoDescription: String {
        return "three months ago"
    }

    var threeMonthsFromNowDescription: String {
        return "three months from now"
    }

    // MARK: - Custom interval string descriptions

    /// Returns a human-readable string for a given number of days
    /// - Parameter days: Number of days (positive or negative)
    /// - Returns: String description
    func daysDescription(_ days: Int) -> String {
        switch days {
        case 0:
            return "today"
        case 1:
            return "tomorrow"
        case -1:
            return "yesterday"
        case 7:
            return "one week from now"
        case -7:
            return "one week ago"
        default:
            if days > 0 {
                return "in \(days) days"
            } else {
                return "\(abs(days)) days ago"
            }
        }
    }

    /// Returns a human-readable string for a given number of months
    /// - Parameter months: Number of months (positive or negative)
    /// - Returns: String description
    func monthsDescription(_ months: Int) -> String {
        switch months {
        case 0:
            return "this month"
        case 1:
            return "next month"
        case -1:
            return "last month"
        case 3:
            return "three months from now"
        case -3:
            return "three months ago"
        default:
            if months > 0 {
                return "in \(months) months"
            } else {
                return "\(abs(months)) months ago"
            }
        }
    }

    /// Returns a human-readable string for a given number of years
    /// - Parameter years: Number of years (positive or negative)
    /// - Returns: String description
    func yearsDescription(_ years: Int) -> String {
        switch years {
        case 0:
            return "this year"
        case 1:
            return "next year"
        case -1:
            return "last year"
        default:
            if years > 0 {
                return "in \(years) years"
            } else {
                return "\(abs(years)) years ago"
            }
        }
    }

    /// Returns a human-readable description of a date combining days, months and years
    /// - Parameters:
    ///   - days: Number of days to add/subtract
    ///   - months: Number of months to add/subtract
    ///   - years: Number of years to add/subtract
    /// - Returns: A combined string description
    func timeDescription(days: Int = 0, months: Int = 0, years: Int = 0) -> String {
        let components = [
            days != 0 ? daysDescription(days) : nil,
            months != 0 ? monthsDescription(months) : nil,
            years != 0 ? yearsDescription(years) : nil,
        ].compactMap { $0 }

        if components.isEmpty {
            return "now"
        } else if components.count == 1 {
            return components[0]
        } else {
            let lastComponent = components.last!
            let previousComponents = components.dropLast().joined(separator: ", ")
            return "\(previousComponents) and \(lastComponent)"
        }
    }
}
