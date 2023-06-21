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
    var uniqueId: String? { get }
    func toEntity(in context: NSManagedObjectContext) -> Entity
}

protocol CoreDataStorageProtocol {
    associatedtype Model
    func getAll() -> [Model]
    func addAll(_ models: [Model])
    func removeAll()
    func add(_ model: Model)
    func remove(_ model: Model)
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
    
    var context: NSManagedObjectContext { persistentContainer.viewContext }
    
    func storage<T, U>() -> CoreDataStorage<T, U> { CoreDataStorage<T, U>(context: context) }
    
}

final class CoreDataStorage<T: NSManagedObject, U>: CoreDataStorageProtocol where U: CoreDataConvertible, U.Entity == T {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAll() -> [U] { getAllEntites().compactMap { U(from: $0) } }
    
    func addAll(_ models: [U]) {
        models.forEach(addEntity)
        trySaveContext()
    }
    
    func add(_ model: U) {
        addEntity(model)
        trySaveContext()
    }
    
    func removeAll() {
        deleteAllEntities()
        trySaveContext()
    }
    
    func remove(_ model: U) {
        findEntities(from: model).forEach(context.delete)
        trySaveContext()
    }
}

private extension CoreDataStorage {
    func getAllEntites() -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        var result = [T]()
        context.performAndWait {
            do {
                let entities = try context.fetch(request)
                result = entities
            } catch {
                print("Failed to fetch \(T.self): \(error)")
            }
        }
        return result
    }
    
    func findEntities(from model: U) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = NSPredicate(format: "uniqueId == %@", model.uniqueId ?? "")
        var result = [T]()
        context.performAndWait {
            do {
                let entity = try context.fetch(request)
                result = entity
            } catch {
                print("Failed to find \(String(describing: T.self)): \(error)")
            }
        }
        return result
    }
    
    func addEntity(_ model: U) {
        guard findEntities(from: model).isEmpty else { return }
        context.performAndWait { _ = model.toEntity(in: context) }
    }
    
    func deleteAllEntities() {
        context.performAndWait {
            let request = T.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Failed to delete all \(String(describing: T.self)): \(error)")
            }
        }
    }
    
    func trySaveContext() {
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



