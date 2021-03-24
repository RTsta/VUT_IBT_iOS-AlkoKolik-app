//
//  VolumeTableInterfaceController.swift
//  AlkoKolik WatchKit Extension
//
//  Created by Arthur Nácar on 22.03.2021.
//

import WatchKit
import Foundation
import WatchConnectivity

class VolumeTableInterfaceController: WKInterfaceController {

    var volumes : [Double]?
    var selectedDrink : DrinkItem?
    private var watchSession: WCSession?
    @IBOutlet weak var volumeTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported(){
            let watchSession = WCSession.default
            watchSession.delegate = self
            watchSession.activate()
        }
        
        if let context = context as? [String:Any?],
           let vol = context["volumes"] as? [Double],
           let drink = context["selectedDrink"] as? DrinkItem{
            volumes = vol
            selectedDrink = drink
        }
        
        if let volumes = volumes {
            volumeTable.setNumberOfRows(volumes.count, withRowType: "VolumeItemRow")
            for index in 0..<volumeTable.numberOfRows {
                guard let controller = volumeTable.rowController(at: index) as? VolumeRowController else { continue }
                controller.volume = volumes[index]
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if let drink = selectedDrink {
            
            let message : [String: Any] = ["drink_id":drink.id, "selectedVolume" : rowIndex ]
            WCSession.default.sendMessage(message,
                                          replyHandler: {(replyMessage) in
                                            print(replyMessage)
                                          }, errorHandler: { (error) in
                                            myDebugPrint(error.localizedDescription, "Error")
                                          })
        }
        self.dismiss()
    }
    
}

extension VolumeTableInterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
}
