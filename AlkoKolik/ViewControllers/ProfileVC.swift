//
//  ProfileVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 03.03.2021.
//

import UIKit

class ProfileVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ProfileVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileViewInfoCell", for: indexPath) as! ProfileViewInfoCell
        return cell
    }
}
