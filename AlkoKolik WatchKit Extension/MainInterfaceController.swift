//
//  MainInterfaceController.swift
//  AlkoKolik WatchKit Extension
//
//  Created by Arthur Nácar on 23.03.2021.
//

import WatchKit
import Foundation
import WatchConnectivity


class MainInterfaceController: WKInterfaceController {

    @IBOutlet weak var bacLabel: WKInterfaceLabel!
    @IBOutlet weak var soberCountDown: WKInterfaceTimer!
    var timeToGetSober : Date = Date() {didSet{
        if timeToGetSober > Date(){
            DispatchQueue.main.async {
                self.soberCountDown.setDate(self.timeToGetSober)
                self.soberCountDown.start()
                do {
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(self.timeToGetSober)
                    UserDefaults.standard.setValue(data, forKey: .lastTimeToSober)
                    print("MainInterfaceController - sober time was saved")
                }catch let error { print("MainInterfaceController - Error - \(error.localizedDescription)")}
            }
        }
    }}
    var currentBAC : Double? {didSet{
        if let currentBAC = currentBAC{
            DispatchQueue.main.async {
                self.bacLabel.setText("\(String(format:"%.2f", currentBAC)) ‰")
            }
        }
    }}
    
    let watchSession = WCSession.default
    
    override init() {
        super.init()
        super.becomeCurrentPage()
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported(){
            let watchSession = WCSession.default
            watchSession.delegate = self
            watchSession.activate()
        }
        
        if let data = UserDefaults.standard.data(forKey: .lastTimeToSober) {
                if let decoded = try? JSONDecoder().decode(Date.self, from: data) {
                    if decoded > Date(){
                        self.timeToGetSober = decoded
                    } else {soberCountDown.stop()
                    }
                }
        }
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        getInfoFromPhone()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func getInfoFromPhone(){
        
        myDebugPrint(WCSession.default.isReachable, "reachable")
        myDebugPrint(WCSession.default.isCompanionAppInstalled, "installed")
        
        let message : [String: Any] = ["infoRequest": true,]
        watchSession.sendMessage(message,
                                      replyHandler: {(replyMessage) in
                                        
                                      }, errorHandler: { (error) in
                                        myDebugPrint(error.localizedDescription, "Error")
                                      })
    }

}
extension MainInterfaceController : WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        getInfoFromPhone()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let bac = message["currentBAC"] as? Double,
           let soberDate = message["soberDate"] as? Date{
            timeToGetSober = soberDate
            currentBAC = bac
        }
        if let favourites = message["favourites"] as? Data{
            do {
                let decoder = JSONDecoder()
                let _ = try decoder.decode([FavouriteDrink].self, from: favourites)
                UserDefaults.standard.setValue(favourites, forKey: .favouriteDrinkKey)
            } catch {
                print("MainInterfaceController - Error - Unable to Decode FavouriteDrinks from iPhone(\(error))")
            }
        }
    }
    
    
}

private extension String {
    static let lastTimeToSober = "lastTimeToSober"
    static let favouriteDrinkKey = "favouriteDrinksKey"
}
