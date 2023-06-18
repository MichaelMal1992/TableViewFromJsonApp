//
//  MainViewModel.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//


import Foundation
import RxSwift
import RxCocoa

final class MainViewModel {
    private let disposeBag = DisposeBag()
    private let employeeService: EmployeeService
    private var isButtonTapped = false
    private var cachedQuery: String?
    
    let sections = BehaviorRelay<[SectionModel]>(value: [])
    let appBarItemTitle = BehaviorRelay<String>(value: Constants.AppBar.hide)
    let isHiddenNoDataLabel = BehaviorRelay<Bool>(value: true)
    let isVisibleSpinner = BehaviorRelay<Bool>(value: true)
    let errorMessage = BehaviorRelay<String?>(value: nil)
    let isRefreshing = BehaviorRelay<Bool>(value: false)
    
    init(employeeService: EmployeeService) {
        self.employeeService = employeeService
        fetchEmployees()
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
        isRefreshing.accept(true)
        fetchEmployees()
    }
    
    private func fetchEmployees() {
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
        isVisibleSpinner.accept(false)
        isRefreshing.accept(false)
        generateSections()
    }
    
    private func errorHandler(_ error: Error) {
        let localizedError = error as? LocalizedError
        let textError = localizedError?.errorDescription ?? error.localizedDescription
        errorMessage.accept(textError)
        isVisibleSpinner.accept(false)
        isRefreshing.accept(false)
    }
    
    private func generateSections() {
        let models = employeeService.fetchFromLocal().filtered(withQuery: cachedQuery)
        let sections = isButtonTapped
        ? generateSingleSection(models)
        : generateGroupedSections(models)
        self.sections.accept(sections)
        isHiddenNoDataLabel.accept(!models.isEmpty)
        
    }
    
    private func generateSingleSection(_ employees: [EmployeeModel]) -> [SectionModel] {
        return [SectionModel(items: employees)]
    }
    
    private func generateGroupedSections(_ employees: [EmployeeModel]) -> [SectionModel] {
        let groupedEmployees = employees.group(by: { $0.gender })
        return groupedEmployees.compactMap { gender, employees in
            SectionModel(header: gender?.rawValue, items: employees.sortedByName())
        }.sortedByHeader()
    }
    
    
    private func setAppBarItemTitle() {
        let title = isButtonTapped ? Constants.AppBar.show : Constants.AppBar.hide
        appBarItemTitle.accept(title)
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

