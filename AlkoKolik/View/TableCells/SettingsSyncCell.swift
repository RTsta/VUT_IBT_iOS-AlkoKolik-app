//
//  SettingsSyncCell.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 07.04.2021.
//

import Foundation
import UIKit

class SettingsSyncCell: UITableViewCell {
  
 enum SyncCellState {
        case normal
        case loading
        case finished
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var importLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var cellState : SyncCellState = .normal {
        didSet{
            switch cellState {
            case .loading:
                importLabel.isHidden = true
                self.accessoryType = .none
                self.activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                break
            case .finished:
                activityIndicator.stopAnimating()
                self.accessoryType = .checkmark
            default:
                activityIndicator.stopAnimating()
                self.accessoryType = .none
                importLabel.isHidden = false
            }
        }
    }
}
