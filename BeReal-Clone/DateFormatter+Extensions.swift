//
//  DateFormatter+Extensions.swift
//  BeReal-Clone
//
//  Created by Derrick Ng on 3/22/23.
//

import Foundation

extension DateFormatter {
    static var postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
}
