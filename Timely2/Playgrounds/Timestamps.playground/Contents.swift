print("hello");
import UIKit

let currentTimestamp = Int(NSDate().timeIntervalSince1970)
print(currentTimestamp)

//let earlyDate = NSCalendar.currentCalendar().dateByAddingUnit(
//    .Hour,
//    value: -1,
//    toDate: NSDate(),
//    options: [])

let today = Date()
let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
let yesterdayTimestamp = Int(yesterday!.timeIntervalSince1970)
print(yesterdayTimestamp)

print("Yesterday: https://hn.algolia.com/api/v1/search?tags=story&page=0&hitsPerPage=100&numericFilters=created_at_i>\(yesterdayTimestamp),created_at_i<\(currentTimestamp)\n")

let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)
let lastWeekTimestamp = Int(lastWeek!.timeIntervalSince1970)
print(lastWeekTimestamp)

let lastWeek2 = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: today)
let lastWeekTimestamp2 = Int(lastWeek2!.timeIntervalSince1970)
print(lastWeekTimestamp2)

print("Last Week: https://hn.algolia.com/api/v1/search?tags=story&page=0&hitsPerPage=100&numericFilters=created_at_i>\(lastWeekTimestamp2),created_at_i<\(currentTimestamp)\n")

let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: today)
let lastMonthTimestamp = Int(lastMonth!.timeIntervalSince1970)
print(lastMonthTimestamp)

print("Last Month: https://hn.algolia.com/api/v1/search?tags=story&page=0&hitsPerPage=100&numericFilters=created_at_i>\(lastMonthTimestamp),created_at_i<\(currentTimestamp)\n")


let yesterdayString = "https://hn.algolia.com/api/v1/search?tags=story&page=0&hitsPerPage=100&numericFilters=created_at_i>$yesterdayTimestamp,created_at_i<$currentTimestamp"
let yesterdayURL = yesterdayString.replacingOccurrences(of: "$yesterdayTimestamp", with: String(yesterdayTimestamp)).replacingOccurrences(of: "$currentTimestamp", with: String(currentTimestamp))
print(yesterdayURL)
