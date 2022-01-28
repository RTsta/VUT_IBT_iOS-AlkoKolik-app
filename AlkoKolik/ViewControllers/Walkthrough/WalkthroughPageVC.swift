//
//  WalkthroughPageController.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 02.05.2021.
//

import Foundation
import UIKit

protocol WalkthroughPageVCDelegate: AnyObject {
    func didUpdatePageIndex(currentIndex: Int)
}

struct WalkrhroughContent {
    let heading : String
    let subheading : String
    let imageFileName : String
}

class WalkthroughPageVC : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    weak var walkthroughDelegate : WalkthroughPageVCDelegate?
    
    
    
    
    
    
    
    
    let pages : [WalkrhroughContent] = [WalkrhroughContent(heading: NSLocalizedString("Welcome", comment: "Welcome heading in walkthrough"),
                                                           subheading: NSLocalizedString("Let's take a quick tour around AlkoKolik app", comment: "Some welcome text"),
                                                           imageFileName: "walkthrough_welcome"),
                                        WalkrhroughContent(heading: NSLocalizedString("Favourites", comment: "Favourites heading in walkthrough"),
                                                           subheading: NSLocalizedString("You can quickly access your favorites from main screen", comment: "text about accessing favourites"),
                                                           imageFileName: "walkthrough_favourites_all"),
                                        WalkrhroughContent(heading: NSLocalizedString("Favourites", comment: "Favourites heading in walkthrough"),
                                                           subheading: NSLocalizedString("To add a drink to your favorites just simply long-press the volume of desired drink", comment: "text about adding to favourites"),
                                                           imageFileName: "walkthrough_favourites_add"),
                                        WalkrhroughContent(heading: NSLocalizedString("Colors", comment: "Colors heading in walkthrough"),
                                                           subheading: NSLocalizedString("The recommended daily limit for the consummation of alcohol is 40g. These colors will help you understand, your drinking habits. For your health, it is better to avoid the red 🙈", comment: "text about colors and their meaning"),
                                                           imageFileName: "walkthrough_colors"),
                                        WalkrhroughContent(heading: NSLocalizedString("HealthKit", comment: "HealthKit heading in walkthrough"),
                                                           subheading: NSLocalizedString("To enable calculation of predictions, we need access to HealhKit for understanding who you are 😊", comment: "text about accessing HealthKit"),
                                                           imageFileName: "walkthrough_healthkit"),
                                        WalkrhroughContent(heading: NSLocalizedString("Notifications", comment: "Notifications heading in walkthrough"),
                                                           subheading: NSLocalizedString("We would like to notifie you, when you get sober, to let you know you cant do whatever you want 🥳", comment: "text about accessing Notifications"),
                                                           imageFileName: "walkthrough_notifications")
    ]
   
    var currentIndex = 0
 
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let startVC = contentViewController(at: 0){
            setViewControllers([startVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentVC).index
        index = index - 1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentVC).index
        index = index + 1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let _contentVC = pageViewController.viewControllers?.first as? WalkthroughContentVC {
                currentIndex = _contentVC.index
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }
        }
    }
    
    func contentViewController(at index: Int) -> WalkthroughContentVC?{
        if index < 0 || index >= pages.count {
            return nil
        }
        let storyboard = UIStoryboard(name: "Walkthrough", bundle: nil)
        if let pageContentVC = storyboard.instantiateViewController(identifier: "WalkthroughContentVC") as? WalkthroughContentVC {
            pageContentVC.imageFile = pages[index].imageFileName
            pageContentVC.heading = pages[index].heading
            pageContentVC.subheading = pages[index].subheading
            pageContentVC.index = index
            return pageContentVC
        }
        return nil
    }
    
    func forwardPage(){
         currentIndex += 1
        if let _nextVC = contentViewController(at: currentIndex){
            setViewControllers([_nextVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func showPageAt(at index: Int){
        if let _nextVC = contentViewController(at: index){
            let direction = (currentIndex <= index) ? UIPageViewController.NavigationDirection.forward : UIPageViewController.NavigationDirection.reverse
            currentIndex = index
            setViewControllers([_nextVC], direction: direction, animated: true, completion: nil)
        }
    }
    
}
