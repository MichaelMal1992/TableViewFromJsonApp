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

final class MainViewController: UIViewController, ConfigurableViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var noDataLabel: UILabel!
    @IBOutlet private weak var spinnerActivity: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    
    private let coordinator: MainCoordinator
    private let viewModel: MainViewModel
    
    init(coordinator: MainCoordinator, viewModel: MainViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: Self.nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        bindingSetup()
        viewModel.loadData()
    }
    
}


//MARK: Setup
private extension MainViewController {
    func configureTableView() {
        tableView.registerCell(EmployeeTableCell.self)
        tableView.refreshControl = refreshControl
    }
    
    func configureNavigationBar() {
        let item = UIBarButtonItem(title: Constants.AppBar.hide, style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = item
        navigationItem.title = Constants.AppBar.employeesTitle
    }
    
    func bindingSetup() {
        bindViewModel()
        bindUserInteractions()
    }
    
    func makeDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel> {
        return RxTableViewSectionedReloadDataSource<SectionModel>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueCell(EmployeeTableCell.self, for: indexPath)
                cell?.setLabel(text: item.name)
                return cell ?? UITableViewCell()
            },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource.sectionModels[sectionIndex].header
            })
    }
    
    func showErrorAlert(with message: String) {
        let title = Constants.Alert.errorTitle
        let actionTitle = Constants.Alert.okTitle.uppercased()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    func goToDetailsScreen(_ employee: EmployeeModel) {
        let navController = coordinator.navigationController
        let childCoordinator = DetailsCoordinator(navigationController: navController, model: employee)
        coordinator.goNext(childCoordinator)
    }
}


//MARK: Binding
private extension MainViewController {
    func bindViewModel() {
        viewModel.appBarItemTitle
            .drive(navigationItem.rightBarButtonItem!.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.sections
            .drive(tableView.rx.items(dataSource: makeDataSource()))
            .disposed(by: disposeBag)
        
        viewModel.isHiddenNoDataLabel
            .drive(noDataLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isVisibleSpinner
            .drive(spinnerActivity.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .drive(with: self, onNext: { sself, error in
                sself.showErrorAlert(with: error)
            }).disposed(by: disposeBag)
        
        
        viewModel.isRefreshing
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
    }
    
    func bindUserInteractions() {
        tableView.rx.modelSelected(EmployeeModel.self)
            .asDriver()
            .drive(with: self, onNext: { sself, employee in
                sself.goToDetailsScreen(employee)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .asDriver()
            .drive(with: self, onNext: { sself, _ in
                sself.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .asDriver()
            .drive(with: self, onNext: { sself, _ in
                sself.searchBar.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(Constants.Number.debounceMiliseconds), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: Driver<String>.empty())
            .drive(onNext: viewModel.searchHandler)
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .asDriver()
            .drive(onNext: viewModel.tapShowOrHideButton)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .asDriver()
            .drive(onNext: viewModel.refreshData)
            .disposed(by: disposeBag)
    }
}
