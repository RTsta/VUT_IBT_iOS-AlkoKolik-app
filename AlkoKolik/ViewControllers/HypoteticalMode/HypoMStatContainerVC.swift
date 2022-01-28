//
//  HypoMStatTableVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 13.10.2021.
//

import UIKit

class HypoMStatContainerVC : UITableViewController {
    
    @IBOutlet weak var peakBACLabel: UILabel!
    @IBOutlet weak var soberAtLabel: UILabel!
    @IBOutlet weak var accountActualSwitch: UISwitch!
    
    var peakBAC : Double = 0 { didSet{
        peakBACLabel.text =  "\(String(format:"%.2f", peakBAC)) ‰"} }
    var soberDate : Date = Date() { didSet{
        if soberDate > Date(){
            soberAtLabel.isHidden = false
            soberAtLabel.text =  "\(dateFormater.string(from: soberDate))"
        } else {soberAtLabel.isHidden = true}
    }}
    
    lazy var dateFormater : DateFormatter = {
        let dateformater = DateFormatter()
        dateformater.dateStyle = .none
        dateformater.timeStyle = .short
        return dateformater
    }()
    
    var delegate : HypoMStatContainerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        accountActualSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        tableView.allowsSelection = false
    }
    
    @objc private func switchChanged(){
        myDebugPrint(accountActualSwitch.isOn, "changed in stats container")
        delegate?.didSwitchedAccountToggle(to: accountActualSwitch.isOn)
    }
    
}

