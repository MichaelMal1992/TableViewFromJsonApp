//
//  EmployeeService.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import RxSwift

typealias EmployeeResult = Result<EmployeeResponseModel?, NetworkError>

final class EmployeeService {
    private let networkManager = NetworkManager.shared
    private let context = CoreDataStorageManager.shared.context
    private let store = CoreDataStorageManager.shared.store(type: Employee.self)
    
    private let disposeBag = DisposeBag()
    
    func fetchFromRemote() -> Observable<[EmployeeModel]> {
        return Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            let url = Constants.Url.loadEmployees
            let task = Task {
                let result: EmployeeResult = await self.networkManager.fetchData(from: url)
                switch result {
                case .success(let data):
                    let employees = data?.data ?? []
                    let saveObservables = employees.map { self.saveToLocal($0) }
                    Observable.merge(saveObservables).subscribe(onNext: { _ in
                        observer.onNext(employees)
                        observer.onCompleted()
                    }, onError: observer.onError(_:))
                    .disposed(by: self.disposeBag)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func saveToLocal(_ model: EmployeeModel) -> Observable<Void> {
        let entity = model.toEntity(in: context)
        return store.save(entity)
    }
    
    func fetchFromLocal() -> Observable<[EmployeeModel]> {
        return store.fetch().map { $0.compactMap(EmployeeModel.init) }
    }
    
    func deleteFromLocal(_ model: EmployeeModel) -> Observable<Void>{
        let entity = model.toEntity(in: context)
        return store.delete(entity)
    }
}
