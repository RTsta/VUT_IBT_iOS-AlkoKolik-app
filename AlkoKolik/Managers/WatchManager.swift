//
//  WatchManager.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 22.03.2021.
//

import Foundation
import WatchConnectivity

class WatchManager : NSObject {
    fileprivate var watchSession: WCSession?
    static let shared : WatchManager = WatchManager()
    
    override init() {
        super.init()
        if !WCSession.isSupported(){
            watchSession = nil
            return
        }
        
        watchSession = WCSession.default
        watchSession?.delegate = self
        watchSession?.activate()
        
    }
}

extension WatchManager : WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let drink = message["drink"] as? DrinkItem, let volume = message["selectedVolume"] as? Int{
            myDebugPrint(drink, "drink")
            myDebugPrint(volume, "volume index")
        }
    }
    
    
}
