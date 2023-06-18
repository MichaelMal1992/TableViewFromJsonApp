//
//  DataStore.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 17.06.23.
//

import CoreData
import RxSwift

protocol DataStore {
    associatedtype T
    func fetch() -> [T]
    func save(_ objects: [T])
    func delete(_ object: T)
}

