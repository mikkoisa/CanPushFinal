//
//  AppDelegate.swift
//  L7.1
//
//  Created by iosdev on 30.3.2017.
//  Copyright © 2017 stuff. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import CoreLocation
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager!
    var beaconRegion: CLBeaconRegion!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (allowed, error) in
        }
        UNUserNotificationCenter.current().delegate = self
        
        locationManager = CLLocationManager()
        locationManager!.requestAlwaysAuthorization()
        locationManager!.allowsBackgroundLocationUpdates = true
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Helvetica", size: 25)!
        ]
        
        return true
    }
    //MARK: Notification functions
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //code
    }
    
    //MARK: Location manager functions
    /*/  func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
     if(state == .inside){
     //When beacon did enter region, ranging will start. As it is called from background, the ranging will only last 10 seconds max.
     print("DID ENTER REGION")
     locationManager.startRangingBeacons(in: beaconRegion)
     }else if(state == .outside){
     print("DID EXIT REGION")
     }
     }*/
    
    func locationManager(_ manager: CLLocationManager!, didEnterRegion region: CLBeaconRegion) {
        print("Entered region: \(region)")
        locationManager.startRangingBeacons(in: beaconRegion)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            print("DID EXIT REGION: uuid: \(beaconRegion.proximityUUID)")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        if (knownBeacons.count > 0) {
            let closestBeacon = knownBeacons[0] as CLBeacon
            print(closestBeacon.proximityUUID)
            
            //gets attachments
            getAttachments(beaconNumber: 0)
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("entering background")
        setRegion()
        locationManager!.delegate = self
        //for testing
        locationManager!.startMonitoring(for: beaconRegion)
        //  RunLoop.current.run()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        //Application will go to foreground. Stop monitoring and remove the delegate.
        print("going to foreground")
        setRegion()
        locationManager!.delegate = nil
        locationManager!.stopMonitoring(for: beaconRegion)
        locationManager!.stopRangingBeacons(in: beaconRegion)
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("Starting")
        setRegion()
        locationManager!.delegate = self
        //for testing:
            locationManager!.startMonitoring(for: beaconRegion)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("terminating")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "L7_1")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK: Beacon functions
    func setRegion() {
        beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "12345678-1234-1234-1234-123456789012")! as UUID, identifier: "IBEACON")
    }
    
    func getAttachments(beaconNumber: Int) {
        let preference = ViewControllerPref().getPref().description
        let parameters: Parameters = [
            "observations": [
                "advertisedId" :
                    ["type": "EDDYSTONE", "id": "NGIzMmQ2NTVmZGNhbnB1cw=="
                ]
            ],
            "namespacedTypes": ["bacon-test-163808/"+preference+""]
        ]
        Alamofire.request("https://proximitybeacon.googleapis.com/v1beta1/beaconinfo:getforobserved?key=AIzaSyD4LqT6gq-es0UPpLuvVT7IiAuxlBEx3hM", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            if let result = response.result.value {
                //       var i = 0
                //        var data: Int = 0
                let JSON = result as! NSDictionary
                let preference = ViewControllerPref().getPref()
                //print(JSON)
                let beacons = JSON["beacons"] as! NSArray
                
                //TÄhän MUUTOSTA
                let beacon = beacons[0] as! NSDictionary
                //TÄHÄN LOPPUU MUTOSTA
                
                let attachments = beacon["attachments"] as! NSArray
                let attachment = attachments[0] as! NSDictionary
                let info = attachment["data"] as! String
                //decode from base64 to string
                let location = Array(Data(base64Encoded: info)!)
                let xmlStr: String = String(bytes: location, encoding: String.Encoding.utf8)!
                
                //Save data into core data and send notification
                if (preference == 0) {
                    ViewControllerMenu().request(location: xmlStr)
                    self.sendMenu()
                } else if (preference == 1) {
                    
                    let stop = Funkkarit.fetchDefaultStop()
                    if stop != nil {
                        
                        Funkkarit.requestTimesByStop(stopId: stop!, time: Int(NSDate().timeIntervalSince1970), deps: 4, completion: { stop in
                            
                            if let data = stop["data"] as? [String: Any],
                                let stopp = data["stop"] as? [String: Any],
                                let stopTimes = stopp["stoptimesForPatterns"] as?  NSArray{
                                
                                var departures: String = ""
                                
                                if let name = stopp["name"] as? String {
                                    departures += "\(name) \n"
                                }
                                for var i in 0..<stopTimes.count {
                                    if let single = stopTimes[i] as? [String: Any] {
                                        if let pattern = single["pattern"] as? [String: Any],
                                            let route = pattern["route"] as? [String: Any] {
                                            if let shortName = route["shortName"] as? String {
                                                departures += "\n\(shortName):  \t\t"
                                                if (shortName.characters.count == 1) {
                                                    departures += "\t"
                                                }
                                            }
                                        }
                                        if let times = single["stoptimes"] as? NSArray {
                                            for var i in 0..<times.count {
                                                if let singleTime = times[i] as? [String: Any] {
                                                    let seconds = singleTime["scheduledDeparture"] as! Int
                                                    var hours = Int(seconds / 3600) % 24
                                                    let mins  = Int(seconds / 60 % 60)
                                                    departures += "\(hours):\(mins<10 ? "0" : "")\(mins)\(i<times.count-1 ? "\n\t\t\t" : "")"
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                                DispatchQueue.main.async(execute: {
                                    self.sendBus(data: departures)
                                })
                            }
                        })
                    } else {
                        print("ei default stoppia")
                    }
                }
            }
            self.locationManager!.stopRangingBeacons(in: self.beaconRegion)
            // self.locationManager!.delegate = nil
        }
    }
    
    
    
    
    func sendMenu() {
        let content = UNMutableNotificationContent()
        content.title = "Lunch menu"
        content.body = ViewControllerMenu().getMenu()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "any", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func sendBus(data: String) {
        let content = UNMutableNotificationContent()
        content.title = "Timetables"
        content.body = data
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "any", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func exitNotif() {
        let content = UNMutableNotificationContent()
        content.title = "Exit notification"
        content.body = "Did exit region"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "any", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func getCourse() -> NSManagedObjectContext  {
        let stuff = persistentContainer.viewContext
        return stuff
    }
    
    func appDelegate () -> AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
}

