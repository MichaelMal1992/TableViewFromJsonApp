//
//  ViewController.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 15.06.23.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MainViewController: UIViewController, XibLoadable {
    var viewModel: MainViewModel?
    var coordinator: MainCoordinator?
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var noDataLabel: UILabel!
    @IBOutlet private weak var spinnerActivity: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        bindViewModel()
    }
    
    private func configureTableView() {
        tableView.registerCell(EmployeeTableCell.self)
        tableView.refreshControl = refreshControl
    }
    
    private func bindViewModel() {
        guard let viewModel else { return }
        
        let dataSource = makeDataSource()
        
        viewModel.appBarItemTitle
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .bind { sSelf, title in
                sSelf.navigationItem.rightBarButtonItem?.title = title
            }
            .disposed(by: disposeBag)
        
        
        viewModel.sections
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.isHiddenNoDataLabel
            .observe(on: MainScheduler.instance)
            .bind(to: noDataLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isVisibleSpinner
            .observe(on: MainScheduler.instance)
            .bind(to: spinnerActivity.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .bind { [weak self] error in
                guard let self, let error else { return }
                self.showErrorAlert(with: error)
            }.disposed(by: disposeBag)
        
        viewModel.isRefreshing
            .observe(on: MainScheduler.instance)
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        setupUserInteraction(with: viewModel)
    }
    
    private func makeDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel> {
        return RxTableViewSectionedReloadDataSource<SectionModel>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueCell(EmployeeTableCell.self, for: indexPath)
                cell?.nameLabel?.text = item.name
                return cell ?? UITableViewCell()
            },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource.sectionModels[sectionIndex].header
            })
    }
    
    private func setupUserInteraction(with viewModel: MainViewModel) {
        tableView.rx.modelSelected(EmployeeModel.self)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { sself, employee in
                sself.coordinator?.goToDetails(with: employee)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.searchBar.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(Constants.Number.debounceMiliseconds), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: viewModel.searchHandler)
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: viewModel.tapShowOrHideButton)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.allEvents)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: viewModel.refreshData)
            .disposed(by: disposeBag)
    }
    
    private func configureNavigationBar() {
        let item = UIBarButtonItem(title: nil, style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = item
        navigationItem.title = Constants.AppBar.employeesTitle
    }
    
    private func showErrorAlert(with message: String) {
        let title = Constants.Alert.errorTitle
        let actionTitle = Constants.Alert.okTitle.uppercased()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default))
        present(alert, animated: true, completion: nil)
    }
    
}
