//
//  UserNotificationManager.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 28.01.2022.
//

import Foundation
import UserNotifications

class UserNotificationManager{
    class NotificationIdentifiers {
        static let soberNotificationIdentifier = "soberNotificationIdentifier"
    }
    
    class func planSoberNotification(for date: Date){
        disableSoberNotification()
        UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
            if notificationSettings.authorizationStatus == .authorized {
                let notificationContent = UNMutableNotificationContent()
                
                //notificationContent.title = "AlkoKolik"
                notificationContent.subtitle = NSLocalizedString("You reached 0‰", comment: "You reached 0‰")
                notificationContent.body = ""
                notificationContent.sound = .default
                
                let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: date), repeats: false)
                // Create Notification Request
                let notificationRequest = UNNotificationRequest(identifier:UserNotificationManager.NotificationIdentifiers.soberNotificationIdentifier,
                                                                content: notificationContent,
                                                                trigger: notificationTrigger)
                // Add Request to User Notification Center
                UNUserNotificationCenter.current().add(notificationRequest) { (error) in
                    if let error = error {
                        print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                    } else {print("User notification - added")}
                }
                
            }
        }
    }
    
    class func disableSoberNotification(){
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            for request in requests {
                if request.identifier == UserNotificationManager.NotificationIdentifiers.soberNotificationIdentifier {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [UserNotificationManager.NotificationIdentifiers.soberNotificationIdentifier])
                }
            }
        }
    }
        
        class func requestAuthorization(actionIfDenied:  (()->Void)?){
            UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
                switch notificationSettings.authorizationStatus {
                case .notDetermined:
                    // Request Authorization
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
                        print("Permission granted: \(granted)")
                    }
                case .denied:
                    print("Application Not Allowed to Display Notifications")
                    actionIfDenied?()
                default:
                    break
                }
            }
            
        }
    }
