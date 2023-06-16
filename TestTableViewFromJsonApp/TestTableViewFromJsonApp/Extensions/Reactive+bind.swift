//
//  Reactive+bind.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import RxSwift
extension Reactive where Base: UIBarButtonItem {
    var title: Binder<String?> {
        return Binder(base) { item, title in
            item.title = title
        }
    }
}
