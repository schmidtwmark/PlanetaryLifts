//
//  Date.swift
//  GoodVibesOnly
//
//  Created by Mark Schmidt on 7/13/23.
//

import Foundation

private var ordinalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter
}()

extension Int {
    var ordinal: String? {
        return ordinalFormatter.string(from: NSNumber(value: self))
    }
}

struct TimelessDate : Hashable, Equatable {
    
    var weekday: Int
    var month: Int
    var day: Int
    var year: Int
    
    func format() -> String {
        let dateFormatter = DateFormatter()
        let weekdayString = dateFormatter.weekdaySymbols[self.weekday - 1]
        let monthString = dateFormatter.monthSymbols[self.month - 1]
        return "\(weekdayString) \(monthString) \(day.ordinal!)"
    }
    
    func date() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.year = year
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.timeZone = .current
        dateComponents.calendar = .current
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    
    // Returns true if the previous date is the day before this one
    func isYesterday(candidate: TimelessDate) -> Bool {
        let candidateDate = candidate.date()
        let dayAfterCandidate = Calendar.current.date(byAdding: .day, value: 1, to: candidateDate)?.timeless()
        return dayAfterCandidate == self
    }
}

extension Date {
    func timeless() -> TimelessDate {
        let components = Calendar.current.dateComponents([.weekday, .month, .day, .year], from: self)
        
        return TimelessDate(weekday: components.weekday!, month: components.month!, day: components.day!, year: components.year!)
    }
    
    func getHourAndMinute() -> (Int, Int) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (components.hour!, components.minute!)
    }
}
