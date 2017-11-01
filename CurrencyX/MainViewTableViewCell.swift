//
//  MainViewTableViewCell.swift
//  CurrencyX
//
//  Created by Ubicomp5 on 10/31/17.
//  Copyright © 2017 Team 5. All rights reserved.
//

import UIKit

class MainViewTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var currencyLabelLbl: UILabel!
    
    @IBOutlet weak var currencyPriceLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
