//
//  SettingSliderCell.swift
//  Yelp
//
//  Created by Dam Vu Duy on 3/17/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

protocol SettingSliderCellDelegate: NSObjectProtocol {
    func onSliderToggle(sender: SettingSliderCell, switcher: UISwitch)
}

class SettingSliderCell: UITableViewCell {

    weak var delegate: SettingSliderCellDelegate?
    
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellSlider: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.selectedBackgroundView?.backgroundColor = UIColor.whiteColor()
        
//        self.backgroundColor = UIColor.whiteColor()
    }

    @IBAction func onSliderToggle(sender: UISwitch) {
        self.delegate?.onSliderToggle(self, switcher: sender)
    }
    
}
