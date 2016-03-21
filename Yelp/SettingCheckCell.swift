//
//  SettingCheckCell.swift
//  Yelp
//
//  Created by Dam Vu Duy on 3/17/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

enum CheckCellState {
    case Uncheck
    case Checked
    case Collapsed
}

protocol SettingCheckCellDelegate: NSObjectProtocol {
    func onIndicateTouched(sender: SettingCheckCell, currentMode: CheckCellState)
}

class SettingCheckCell: UITableViewCell {

    weak var delegate: SettingCheckCellDelegate?
    
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellImageIndicate: UIImageView!
    
    var cellMode: CheckCellState = .Collapsed {
        didSet {
            switch cellMode {
            case .Uncheck:
                cellImageIndicate.image = UIImage(named: "uncheck")
                break
            case .Checked:
                cellImageIndicate.image = UIImage(named: "checked")
                break
            case .Collapsed:
                cellImageIndicate.image = UIImage(named: "expand")
                break
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
