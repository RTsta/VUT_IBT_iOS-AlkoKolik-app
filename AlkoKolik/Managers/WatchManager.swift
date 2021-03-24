//
//  WatchManager.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 22.03.2021.
//

import Foundation
import WatchConnectivity

class WatchManager : NSObject {
    
    static let shared : WatchManager = WatchManager()
    
    private var watchSession = WCSession.default
    
    override init() {
        super.init()
        
        if isSuported() {
            watchSession.delegate = self
            watchSession.activate()
        }
    }
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
}

extension WatchManager: WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
        self.watchSession.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        if let drinkId = message["drink_id"] as? Int,
           let volume = message["selectedVolume"] as? Int,
           let drink = ListOfDrinksManager.findDrink(drink_id: drinkId){
            DispatchQueue.main.async {
                CoreDataManager.insertRecord(drink: drink, volumeOpt: volume, time: Date())
            }
        }
        
        if let request = message["infoRequest"] as? Bool,
           request == true {
            NotificationCenter.default.post(name: .watchRequestedUpdate, object: nil)
        }
        
        if let drinkId = message["drink_id"] as? Int,
           let volume = message["selectedFavouriteVolume"] as? Double,
           let drink = ListOfDrinksManager.findDrink(drink_id: drinkId){
            DispatchQueue.main.async {
                CoreDataManager.insertRecord(drink: drink, volumeOpt: 0, time: Date(), volumeMl: volume)
            }
        }
        
        
        replyHandler(["message":"iPhone recieved message"])
    }
    
    func sendMessage(_ message: [String:Any], replyHandler: (([String:Any])->Void)?, errorHandler: ((Error)->Void)?){
        watchSession.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }
}
