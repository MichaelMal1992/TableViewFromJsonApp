//
//  MainViewModel.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//


import Foundation
import RxSwift
import RxCocoa

final class MainViewModel: AssociatedViewModel {
    private let disposeBag = DisposeBag()
    private let employeeService: EmployeeService
    private var isButtonTapped = false
    private var cachedQuery: String?
    
    private let _sections = PublishRelay<[SectionModel]>()
    private let _appBarItemTitle = PublishRelay<String>()
    private let _isHiddenNoDataLabel = PublishRelay<Bool>()
    private let _isVisibleSpinner = PublishRelay<Bool>()
    private let _errorMessage = PublishRelay<String>()
    private let _isRefreshing = PublishRelay<Bool>()
    
    var sections: Driver<[SectionModel]> { _sections.asDriver(onErrorDriveWith: Driver.empty()) }
    var appBarItemTitle: Driver<String> { _appBarItemTitle.asDriver(onErrorDriveWith: Driver.empty()) }
    var isHiddenNoDataLabel: Driver<Bool> { _isHiddenNoDataLabel.asDriver(onErrorDriveWith: Driver.empty()) }
    var isVisibleSpinner: Driver<Bool> { _isVisibleSpinner.asDriver(onErrorDriveWith: Driver.empty()) }
    var errorMessage: Driver<String> { _errorMessage.asDriver(onErrorDriveWith: Driver.empty()) }
    var isRefreshing: Driver<Bool> { _isRefreshing.asDriver(onErrorDriveWith: Driver.empty()) }
    
    init(employeeService: EmployeeService) {
        self.employeeService = employeeService
    }
    
    func tapShowOrHideButton() {
        isButtonTapped.toggle()
        setAppBarItemTitle()
        generateSections()
    }
    
    func searchHandler(_ query: String) {
        cachedQuery = query
        generateSections()
    }
    
    func refreshData() {
        _isRefreshing.accept(true)
        loadData()
    }
    
    func loadData() {
        employeeService.fetchFromRemote()
            .subscribe(
                onSuccess: { [weak self] employees in
                    guard let self else { return }
                    self.succesHundler(employees)},
                onFailure: { [weak self] error in
                    guard let self else { return }
                    self.errorHandler(error)
                }).disposed(by: disposeBag)
    }
    
    private func succesHundler(_ employees: [EmployeeModel]) {
        employeeService.updateLocal(employees)
        _isVisibleSpinner.accept(false)
        _isRefreshing.accept(false)
        generateSections()
    }
    
    private func errorHandler(_ error: Error) {
        let localizedError = error as? LocalizedError
        let textError = localizedError?.errorDescription ?? error.localizedDescription
        _errorMessage.accept(textError)
        _isVisibleSpinner.accept(false)
        _isRefreshing.accept(false)
    }
    
    private func generateSections() {
        let models = employeeService.fetchFromLocal().filtered(withQuery: cachedQuery)
        let sections = isButtonTapped
        ? generateSingleSection(models)
        : generateGroupedSections(models)
        _sections.accept(sections)
        _isHiddenNoDataLabel.accept(!models.isEmpty)
        
    }
    
    private func generateSingleSection(_ employees: [EmployeeModel]) -> [SectionModel] {
        return [SectionModel(items: employees.sortedByName())]
    }
    
    private func generateGroupedSections(_ employees: [EmployeeModel]) -> [SectionModel] {
        let groupedEmployees = employees.group(by: { $0.gender })
        return groupedEmployees.compactMap { gender, employees in
            SectionModel(header: gender?.rawValue, items: employees.sortedByName())
        }.sortedByHeader()
    }
    
    
    private func setAppBarItemTitle() {
        let title = isButtonTapped ? Constants.AppBar.show : Constants.AppBar.hide
        _appBarItemTitle.accept(title)
    }
}

private extension Array where Element == EmployeeModel {
    func sortedByName() -> [Element] {
        return sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
    
    func filtered(withQuery query: String?) -> [Element] {
        guard let query, !query.isEmpty else { return self }
        return filter { $0.name?.contains(query) == true }
    }
}

private extension Array where Element == SectionModel {
    func sortedByHeader() -> [Element] {
        return sorted { ($0.header ?? "") < ($1.header ?? "") }
    }
}

