//
//  URLComponents+addOrModifyQueryItem.swift
//  Timely2
//
//  Created by Mihai Leonte on 1/5/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

extension URLComponents {
    mutating func addOrModify(_ queryItem: URLQueryItem) {
        
        if let _ = self.queryItems {
            
            var queryItemWasFound: Bool = false
            
            for (index, item) in self.queryItems!.enumerated() {
                if item.name == queryItem.name {
                    queryItemWasFound = true
                    self.queryItems?[index].value = queryItem.value
                }
            }
            
            if !queryItemWasFound {
                self.queryItems?.append(queryItem)
            }
            
        } else {
            self.queryItems = [queryItem]
        }
        
    }
}
