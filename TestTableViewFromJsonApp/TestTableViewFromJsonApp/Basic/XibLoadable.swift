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

extension XibLoadable where Self: UIViewController {
    static var nibName: String {
        return String(describing: self)
    }
    
    static func instantiate() -> Self {
        return Self(nibName: nibName, bundle: nil)
    }
}

extension XibLoadable where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
}
