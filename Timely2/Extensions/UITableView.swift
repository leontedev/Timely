//
//  UITableView.swift
//  Timely2
//
//  Created by Mihai Leonte on 2/26/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

extension UITableView {
    
    func scrollToFirst() {
        
        self.reloadData()
        for i in 0..<self.numberOfSections {
            
            if self.numberOfRows(inSection: i) != 0 {
                
                self.scrollToRow(at: IndexPath(row: 0, section: i), at: .top, animated: true)
                break
            }
        }
    }
}
