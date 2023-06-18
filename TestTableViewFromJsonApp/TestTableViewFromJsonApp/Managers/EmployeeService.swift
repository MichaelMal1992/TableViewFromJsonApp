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
    private let storage = CoreDataStorageManager.shared.storage(Employee.self, EmployeeModel.self)
    
    private let disposeBag = DisposeBag()
    
    private var single: Single<[EmployeeModel]> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            let url = Constants.Url.loadEmployees
            let task = Task {
                let result: EmployeeResult = await self.networkManager.fetchData(from: url)
                switch result {
                case .success(let data):
                    let employees = data?.data ?? []
                    single(.success(employees))
                    self.saveToLocal(employees)
                case.failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create { task.cancel() }
        }
    }
    
    func fetchFromRemote() -> Single<[EmployeeModel]> {
        return single
            .subscribe(on: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
    }
    
    func saveToLocal(_ models: [EmployeeModel]) {
        storage.saveToLocal(models)
    }
    
    func fetchFromLocal() -> [EmployeeModel] {
        storage.fetchLocalData()
    }
    
    func deleteFromLocal(_ model: EmployeeModel) {
        //        let entity = model.toEntity(in: context)
        //        store.delete(entity)
    }
}
