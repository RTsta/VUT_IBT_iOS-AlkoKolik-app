//
//  WalkthroughVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 02.05.2021.
//

import Foundation
import UIKit

class WalkthroughVC : UIViewController, WalkthroughPageVCDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    @IBAction func pageControlValueChanged(_ sender: Any) {
        walkthroughPageVC?.showPageAt(at: pageControl.currentPage)
        updateUI()
    }
    var walkthroughPageVC : WalkthroughPageVC?
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if let index = walkthroughPageVC?.currentIndex {
            switch index {
            case 0...3:
                walkthroughPageVC?.forwardPage()
            case 4:
                dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
        updateUI()
    }
    @IBAction func skipButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? WalkthroughPageVC {
            walkthroughPageVC = dest
            walkthroughPageVC?.walkthroughDelegate = self
            pageControl.numberOfPages = dest.pages.count
        }
    }
    
    func updateUI(){
        if let index = walkthroughPageVC?.currentIndex {
            switch index {
            case 0...3:
                nextButton.setTitle(NSLocalizedString("NEXT", comment: "next item button in walkthrough"), for: .normal)
                skipButton.isHidden = false
            case 4:
                nextButton.setTitle(NSLocalizedString("GET STARTED", comment: "GET STARTED item button in walkthrough"), for: .normal)
                skipButton.isHidden = true
                HealthKitManager.authorizeHealthKit { (authorized, error) in
                    guard authorized else {
                        print("not authorized")
                        return // TODO: what error
                    }
                }
            default:
                break
            }
            pageControl.currentPage = index
        }
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
}
