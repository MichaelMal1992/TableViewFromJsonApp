//
//  CoreDataStorageManager.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 17.06.23.
//

import RxSwift
import CoreData

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
    
    func store<T: NSManagedObject>(type: T.Type) -> CoreDataStore<T> {
        return CoreDataStore<T>(context: context)
    }
    
}

final class CoreDataStore<T: NSManagedObject>: DataStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetch() -> Observable<[T]> {
        return fetchRequest()
    }
    
    func save(_ object: T) -> Observable<Void> {
        return saveRequest()
    }
    
    func delete(_ object: T) -> Observable<Void> {
        context.delete(object)
        return saveRequest()
    }
    
    private func fetchRequest() -> Observable<[T]> {
        return Observable.create { [weak self] observer in
            guard let self else {
                observer.onError(NSError())
                return Disposables.create()
            }
            
            let request = NSFetchRequest<T>(entityName: String(describing: T.self))
            self.tryFetch(request: request, observer: observer)
            
            return Disposables.create()
        }
    }
    
    private func saveRequest() -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self else {
                observer.onError(NSError())
                return Disposables.create()
            }
            
            guard self.context.hasChanges else {
                observer.onNext(())
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.trySave(observer: observer)
            
            return Disposables.create()
        }
    }
    
    private func tryFetch(request: NSFetchRequest<T>, observer: AnyObserver<[T]>) {
        do {
            let objects = try context.fetch(request)
            observer.onNext(objects)
            observer.onCompleted()
        } catch {
            observer.onError(error)
        }
    }
    
    private func trySave(observer: AnyObserver<Void>) {
        do {
            try context.save()
            observer.onNext(())
            observer.onCompleted()
        } catch {
            observer.onError(error)
        }
    }
    
}



