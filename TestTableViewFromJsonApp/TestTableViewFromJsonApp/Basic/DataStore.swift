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
    func fetch() -> Observable<[T]>
    func save(_ object: T) -> Observable<Void>
    func delete(_ object: T) -> Observable<Void>
}

