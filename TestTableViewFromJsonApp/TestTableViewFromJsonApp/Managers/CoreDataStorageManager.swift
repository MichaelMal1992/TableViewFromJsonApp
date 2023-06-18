//
//  CoreDataStorageManager.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 17.06.23.
//

import RxSwift
import CoreData

protocol CoreDataConvertible {
    associatedtype Entity: NSManagedObject
    init?(from entity: Entity)
    func toEntity(in context: NSManagedObjectContext) -> Entity
}

protocol CoreDataStorageProtocol {
    associatedtype Model
    func fetchLocalData() -> [Model]
    func saveToLocal(_ models: [Model])
}

final class CoreDataStorageManager {
    
    static let shared = CoreDataStorageManager()
    
    private init() {}
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.CoreData.name)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                print(error.userInfo)
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func storage<T, U> (_ entityType: T.Type, _ modelType: U.Type) -> CoreDataStorage<T, U> {
        return CoreDataStorage<T, U>(context: context)
    }
    
}

final class CoreDataStorage<T: NSManagedObject, U>: CoreDataStorageProtocol where U: Codable, U: CoreDataConvertible, U.Entity == T {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchLocalData() -> [U] {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { U(from: $0) }
        } catch {
            print("Failed to fetch \(T.self): \(error)")
            return []
        }
    }
    
    func saveToLocal(_ models: [U]) {
        let currentEntities = fetchLocalData()
        guard currentEntities.isEmpty else { return }
        _ = models.compactMap({ $0.toEntity(in: context) })
        trySaveContext()
    }
    
    private func trySaveContext() {
        context.performAndWait {
            guard context.hasChanges else { return }
            do {
                try context.save()
            } catch {
                print("Failed to save \(String(describing: T.self)): \(error)")
            }
        }
    }
}



