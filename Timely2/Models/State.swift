//
//  State.swift
//  Timely2
//
//  Created by Mihai Leonte on 2/14/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//



//Track State of View Controllers
enum State {
//    static func == (lhs: State, rhs: State) -> Bool {
//        return lhs.r == rhs
//    }
    
    case loading
    //case paging([Recording], next: Int)
    case populated
    case empty
    case error(Error)
    
    
    
    //    var currentRecordings: [Recording] {
    //        switch self {
    //        case .paging(let recordings, _):
    //            return recordings
    //        case .populated(let recordings):
    //            return recordings
    //        default:
    //            return []
    //        }
    //    }
}
