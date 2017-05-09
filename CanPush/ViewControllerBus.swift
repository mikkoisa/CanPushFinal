//
//  ViewController.swift
//  reitti
//
//  Created by iosdev on 27.4.2017.
//  Copyright © 2017 org. All rights reserved.
//

import UIKit

class ViewControllerBus: UIViewController {
    
    
    @IBOutlet weak var timetable: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Funkkarit.request(toLat: 60.1695862, toLon: 24.9333744)
        
        //self.timetable.text = Funkkarit.fetchDefaultStopData()
        //if let data = Funkkarit.fetchDefaultStopData() != nil {
        getDefaultBusStopListPrettified()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.getDefaultBusStopListPrettified()
        //self.timetable.text = Funkkarit.fetchDefaultStopData()
    }
    override func viewWillAppear(_ animated: Bool) {
        //self.getDefaultBusStopListPrettified()
    }
    
    func getDefaultBusStopListPrettified() {
        let stop = Funkkarit.fetchDefaultStop()
        if stop != nil {
            
            Funkkarit.requestTimesByStop(stopId: stop!, time: Int(NSDate().timeIntervalSince1970), deps: 4, completion: { stop in
                
                if let data = stop["data"] as? [String: Any],
                    let stopp = data["stop"] as? [String: Any],
                    let stopTimes = stopp["stoptimesForPatterns"] as?  NSArray{
                    //print(stopTimes)
                    
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
                                        //print(singleTime["scheduledArrival"])
                                        //print(singleTime["scheduledDeparture"])
                                        
                                        let seconds = singleTime["scheduledDeparture"] as! Int
                                        
                                        var hours = Int(seconds / 3600) % 24
                                        let mins  = Int(seconds / 60 % 60)
                                        //let secs = Int(seconds % 60)
                                        
                                        //print("\(hours) \(mins) \(secs)")
                                        departures += "\(hours):\(mins<10 ? "0" : "")\(mins)\(i<times.count-1 ? "\n\t\t\t" : "")"
                                        
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                    //print("subtitleeeee \(subtitle)")
                    //print(departures)
                    //DispatchQueue.main.async(execute: {
                    //Funkkarit.saveDefaultStopData(stop: departures)
                    //DispatchQueue.main.async(execute: {
                    //self.timetable.text = Funkkarit.fetchDefaultStopData()
                    //})
                    DispatchQueue.main.async(execute: {
                        
                        self.timetable.text = departures
                    })
                    
                    //completion(departures)
                    
                    //print(Funkkarit.fetchDefaultStopData() ?? "miksei toimi")
                    //subtitle = ""
                }
                
            }
            )
            
            
            
        } else {
            
            print("ei default stoppia")
        }
        
    }
    
    
}


