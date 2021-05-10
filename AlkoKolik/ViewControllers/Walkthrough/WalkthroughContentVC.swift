//
//  WalkthroughContentVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 02.05.2021.
//

import Foundation
import UIKit

class WalkthroughContentVC : UIViewController {
    
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subheadingLabel: UILabel!
    
    var index : Int = 0
    var heading : String = ""
    var subheading : String = ""
    var imageFile : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentImage.image = UIImage(named: imageFile)
        headingLabel.text = heading
        subheadingLabel.text = subheading
    }
}
