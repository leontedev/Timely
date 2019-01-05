//
//  HNFeed.swift
//  Timely2
//
//  Created by Mihai Leonte on 12/21/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import Foundation

extension Calendar.Component: Decodable {
    public init(from decoder: Decoder) throws {
        let label = try decoder.singleValueContainer().decode(String.self)
        switch label {
        case "calendar": self = .calendar
        case "day": self = .day
        case "era": self = .era
        case "hour": self = .hour
        case "minute": self = .minute
        case "month": self = .month
        case "nanosecond": self = .nanosecond
        case "quarter": self = .quarter
        case "second": self = .second
        case "timeZone": self = .timeZone
        case "weekOfMonth": self = .weekOfMonth
        case "weekOfYear": self = .weekOfYear
        case "weekday": self = .weekday
        case "weekdayOrdinal": self = .weekdayOrdinal
        case "year": self = .year
        case "yearForWeekOfYear": self = .yearForWeekOfYear
        default: self = .day
        }
    }
}

enum HNFeedType: String, Decodable {
    case timely
    case official
    case algolia
}

struct Feed: Decodable {
    var feedName: String
    var feedURL: String
    var feedType: HNFeedType
    var fromCalendarComponentByAdding: Calendar.Component?
    var fromCalendarComponentValue: Int?
}
