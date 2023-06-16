//
//  EmployeeService.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import RxSwift

typealias EmployeeResult = Result<EmployeeResponseModel?, NetworkError>

class EmployeeService {
    private let networkManager = NetworkManager.shared
    
    func fetchEmployees() -> Observable<[EmployeeModel]> {
        return Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            let url = Constants.Url.loadEmployees
            let task = Task {
                let result: EmployeeResult = await self.networkManager.fetchData(from: url)
                switch result {
                case .success(let data):
                    observer.onNext(data?.data ?? [])
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
