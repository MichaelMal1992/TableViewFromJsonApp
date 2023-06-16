//
//  Sequence+group.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import Foundation
extension Sequence {
    func group<T: Hashable>(by key: (Element) -> T) -> [T: [Element]] {
        return Dictionary(grouping: self, by: key)
    }
}
