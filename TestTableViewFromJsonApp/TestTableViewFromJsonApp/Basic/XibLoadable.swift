//
//  XibLoadable.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import UIKit

protocol XibLoadable {
    static var nibName: String { get }
}

extension XibLoadable {
    static var nibName: String {
        return String(describing: self)
    }
}

extension XibLoadable where Self: UIView {
    static func nib() -> UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
}
