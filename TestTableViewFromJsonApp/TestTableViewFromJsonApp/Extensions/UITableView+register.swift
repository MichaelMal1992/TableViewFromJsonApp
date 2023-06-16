//
//  UITableView+register.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import UIKit

extension UITableView {
    func registerCell<T: UITableViewCell>(_ cellType: T.Type) where T: XibLoadable {
        register(T.nib(), forCellReuseIdentifier: T.nibName)
    }
    
    func dequeueCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T? where T: XibLoadable {
        return dequeueReusableCell(withIdentifier: T.nibName, for: indexPath) as? T
    }
}

