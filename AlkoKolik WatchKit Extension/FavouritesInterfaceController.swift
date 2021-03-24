//
//  FavouritesInterfaceController.swift
//  AlkoKolik WatchKit Extension
//
//  Created by Arthur Nácar on 23.03.2021.
//

import WatchKit
import Foundation
import WatchConnectivity


class FavouritesInterfaceController: WKInterfaceController {

    @IBOutlet weak var group1: WKInterfaceGroup!
    @IBOutlet weak var group2: WKInterfaceGroup!
    @IBOutlet weak var group3: WKInterfaceGroup!
    @IBOutlet weak var group4: WKInterfaceGroup!
    @IBOutlet weak var group5: WKInterfaceGroup!
    @IBOutlet weak var group6: WKInterfaceGroup!
    @IBOutlet weak var group7: WKInterfaceGroup!
    
    @IBOutlet weak var btn11: WKInterfaceButton!
    
    @IBOutlet weak var btn21: WKInterfaceButton!
    @IBOutlet weak var btn22: WKInterfaceButton!
    
    @IBOutlet weak var btn31: WKInterfaceButton!
    @IBOutlet weak var btn32: WKInterfaceButton!
    @IBOutlet weak var btn33: WKInterfaceButton!
    
    @IBOutlet weak var btn41: WKInterfaceButton!
    @IBOutlet weak var btn42: WKInterfaceButton!
    @IBOutlet weak var btn43: WKInterfaceButton!
    @IBOutlet weak var btn44: WKInterfaceButton!
    
    @IBOutlet weak var btn51: WKInterfaceButton!
    @IBOutlet weak var btn52: WKInterfaceButton!
    @IBOutlet weak var btn53: WKInterfaceButton!
    @IBOutlet weak var btn54: WKInterfaceButton!
    @IBOutlet weak var btn55: WKInterfaceButton!
    
    @IBOutlet weak var btn61: WKInterfaceButton!
    @IBOutlet weak var btn62: WKInterfaceButton!
    @IBOutlet weak var btn63: WKInterfaceButton!
    @IBOutlet weak var btn64: WKInterfaceButton!
    @IBOutlet weak var btn65: WKInterfaceButton!
    @IBOutlet weak var btn66: WKInterfaceButton!
    
    @IBOutlet weak var btn71: WKInterfaceButton!
    @IBOutlet weak var btn72: WKInterfaceButton!
    @IBOutlet weak var btn73: WKInterfaceButton!
    @IBOutlet weak var btn74: WKInterfaceButton!
    @IBOutlet weak var btn75: WKInterfaceButton!
    @IBOutlet weak var btn76: WKInterfaceButton!
    @IBOutlet weak var btn77: WKInterfaceButton!
    
    @IBAction func btn1action() {btnPressed(number: 1)}
    @IBAction func btn2action() {btnPressed(number: 2)}
    @IBAction func btn3action() {btnPressed(number: 3)}
    @IBAction func btn4action() {btnPressed(number: 4)}
    @IBAction func btn5action() {btnPressed(number: 5)}
    @IBAction func btn6action() {btnPressed(number: 6)}
    @IBAction func btn7action() {btnPressed(number: 7)}
    
    
    var favourites: [FavouriteDrink]?
    var completeFavList: [DrinkItem]?
    private var watchSession: WCSession?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        
        if WCSession.isSupported(){
            let watchSession = WCSession.default
            watchSession.delegate = self
            watchSession.activate()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        loadUserDefaults()
        loadCompleteFavList()
        setupAppearance()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension FavouritesInterfaceController{
    
    func loadUserDefaults(){
        if let data = UserDefaults.standard.data(forKey: .favouriteDrinkKey) {
            do {
                let decoder = JSONDecoder()
                let drinks = try decoder.decode([FavouriteDrink].self, from: data)
                favourites = drinks
                return
            } catch {
                print("Unable to Decode FavouriteDrinks (\(error))")
            }
        }
    }
    
    func loadCompleteFavList(){
        var result : [DrinkItem] = []
        if let favourites = favourites {
        for  d in favourites {
            let tmp = ListOfDrinksManager.findDrink(drink_id: d.drinkId)
            guard let _ = tmp else {continue}
            result.append(tmp!)
        }
        }
        completeFavList = result
    }
    
    func btnPressed(number: Int){
        if let favourites = favourites, favourites.count > number-1 {
            let message : [String: Any] = ["drink_id":favourites[number-1].drinkId, "selectedFavouriteVolume" : favourites[number-1].volume ]
            WCSession.default.sendMessage(message,
                                          replyHandler: {(replyMessage) in
                                            print(replyMessage)
                                          }, errorHandler: { (error) in
                                            myDebugPrint(error.localizedDescription, "Error")
                                          })
        }
    }
    
    func setupAppearance(){
        group1.setHidden(true)
        group2.setHidden(true)
        group3.setHidden(true)
        group4.setHidden(true)
        group5.setHidden(true)
        group6.setHidden(true)
        group7.setHidden(true)
        
        guard favourites?.count == completeFavList?.count else { return }
        
        switch favourites?.count {
        case 1:
            group1.setHidden(false)
            btn11.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![0].type))
            btn11.setBackgroundImage(imageFor(drinkType: completeFavList![0].type))
        case 2:
            group2.setHidden(false)
            btn21.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![0].type))
            btn21.setBackgroundImage(imageFor(drinkType: completeFavList![0].type))
            btn22.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![1].type))
            btn22.setBackgroundImage(imageFor(drinkType: completeFavList![1].type))
        case 3:
            group3.setHidden(false)
            btn31.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![0].type))
            btn31.setBackgroundImage(imageFor(drinkType: completeFavList![0].type))
            btn32.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![1].type))
            btn32.setBackgroundImage(imageFor(drinkType: completeFavList![1].type))
            btn33.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![2].type))
            btn33.setBackgroundImage(imageFor(drinkType: completeFavList![2].type))
        case 4:
            group4.setHidden(false)
            btn41.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![0].type))
            btn41.setBackgroundImage(imageFor(drinkType: completeFavList![0].type))
            btn42.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![1].type))
            btn42.setBackgroundImage(imageFor(drinkType: completeFavList![1].type))
            btn43.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![2].type))
            btn43.setBackgroundImage(imageFor(drinkType: completeFavList![2].type))
            btn44.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![3].type))
            btn44.setBackgroundImage(imageFor(drinkType: completeFavList![3].type))
        case 5:
            group5.setHidden(false)
            btn51.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![0].type))
            btn51.setBackgroundImage(imageFor(drinkType: completeFavList![0].type))
            btn52.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![1].type))
            btn52.setBackgroundImage(imageFor(drinkType: completeFavList![1].type))
            btn53.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![2].type))
            btn53.setBackgroundImage(imageFor(drinkType: completeFavList![2].type))
            btn54.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![3].type))
            btn54.setBackgroundImage(imageFor(drinkType: completeFavList![3].type))
            btn55.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![4].type))
            btn55.setBackgroundImage(imageFor(drinkType: completeFavList![4].type))
        case 6:
            group6.setHidden(false)
            btn61.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![0].type))
            btn61.setBackgroundImage(imageFor(drinkType: completeFavList![0].type))
            btn62.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![1].type))
            btn62.setBackgroundImage(imageFor(drinkType: completeFavList![1].type))
            btn63.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![2].type))
            btn63.setBackgroundImage(imageFor(drinkType: completeFavList![2].type))
            btn64.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![3].type))
            btn64.setBackgroundImage(imageFor(drinkType: completeFavList![3].type))
            btn65.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![4].type))
            btn65.setBackgroundImage(imageFor(drinkType: completeFavList![4].type))
            btn66.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![5].type))
            btn66.setBackgroundImage(imageFor(drinkType: completeFavList![5].type))
        case 7:
            group7.setHidden(false)
            btn71.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![0].type))
            btn71.setBackgroundImage(imageFor(drinkType: completeFavList![0].type))
            btn72.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![1].type))
            btn72.setBackgroundImage(imageFor(drinkType: completeFavList![1].type))
            btn73.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![2].type))
            btn73.setBackgroundImage(imageFor(drinkType: completeFavList![2].type))
            btn74.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![3].type))
            btn74.setBackgroundImage(imageFor(drinkType: completeFavList![3].type))
            btn75.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![4].type))
            btn75.setBackgroundImage(imageFor(drinkType: completeFavList![4].type))
            btn76.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![5].type))
            btn76.setBackgroundImage(imageFor(drinkType: completeFavList![5].type))
            btn77.setBackgroundColor(UIColor.colorFor(drinkType: completeFavList![6].type))
            btn77.setBackgroundImage(imageFor(drinkType: completeFavList![6].type))
        default:
            break
        }
    }
    
    private func imageFor(drinkType: DrinkType) -> UIImage? {
        switch drinkType {
        case .beer:
            return UIImage(named: "watch_beer")
        case .wine, .cider:
            return UIImage(named: "watch_wine")
        case .spirit, .liqueur:
            return UIImage(named: "watch_spirit")
        case .cocktail:
            return UIImage(named: "watch_cocktail")
        default:
            return nil
        }
    }
}

extension FavouritesInterfaceController : WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
}

private extension String {
    static let favouriteDrinkKey = "favouriteDrinksKey"
}
