//
//  EmployeeCell.swift
//  TestTableViewFromJsonApp
//
//  Created by Mikhail Malaschenko on 16.06.23.
//

import UIKit

final class EmployeeTableCell: UITableViewCell, XibLoadable {
    @IBOutlet weak private var nameLabel: UILabel!
    
    func setLabel(text: String?) {
        nameLabel.text = text
    }
}

