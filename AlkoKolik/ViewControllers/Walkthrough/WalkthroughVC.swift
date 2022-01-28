//
//  WalkthroughVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 02.05.2021.
//

import Foundation
import UIKit
import UserNotifications

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
            case 0...4:
                walkthroughPageVC?.forwardPage()
            case 5:
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
                nextButton.setTitle(NSLocalizedString("NEXT", comment: "next item button in walkthrough"), for: .normal)
                skipButton.isHidden = false
                HealthKitManager.authorizeHealthKit { (authorized, error) in
                    guard authorized else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: NSLocalizedString("HealthKit", comment: "HealthKit info unavaibile warning"),
                                                          message: NSLocalizedString("Sorry, there is a problem with HelthKit. Please check app premissions on health data", comment: "Sorry, there is a problem with HelthKit. Please check app premissions on health data"),
                                                          preferredStyle: .alert)
                            
                            if let url = URL(string: "x-apple-health://") {
                                if UIApplication.shared.canOpenURL(url) {
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Open Health", comment: "Open Apple Health app"), style: UIAlertAction.Style.default) {_ in
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    })
                                }
                            }

                            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: UIAlertAction.Style.cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                }
            case 5:
                nextButton.setTitle(NSLocalizedString("GET STARTED", comment: "GET STARTED item button in walkthrough"), for: .normal)
                skipButton.isHidden = false
                UserNotificationManager.requestAuthorization(actionIfDenied: {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: NSLocalizedString("Notifications disabeled", comment: "Title for disabled user notifications"),
                                                      message: NSLocalizedString("Sorry, notifications are diasbeled. Please, check the Settings to enable them again", comment: "Sorry, notifications are diasbeled. Please, check the Settings to enable them again"),
                                                      preferredStyle: .alert)
                        
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Open Settings", comment: "Open Apple Settings app"), style: UIAlertAction.Style.default) {_ in
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                })
                            }
                        }

                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: UIAlertAction.Style.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
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
