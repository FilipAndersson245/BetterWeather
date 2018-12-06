//
//  SearchResultTableViewCell.swift
//  BetterWeather
//
//  Created by Marcus Gullstrand on 2018-12-04.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var title: UILabel!
    
    // MARK: - Overridden methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
