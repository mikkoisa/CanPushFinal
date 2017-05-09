//
//  mapViewController.swift
//  reitti
//
//  Created by iosdev on 2.5.2017.
//  Copyright © 2017 org. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class mapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    //@IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var nappula: UIButton!
    
    @IBOutlet weak var addressField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentAddress: String = ""
    
    var planStr: String = ""
    
    var selectedAnnotation: Stop?
    
    let locManager = CLLocationManager()
    var shit: Bool = false
    var lastLocation: CLLocation?
    
    var stopsNearby: [MKAnnotation] = []
    
    let stopPin = UIImage(named: "stop pin")
    let railPin = UIImage(named: "rail pin")
    let busIcon = UIImage(named: "bus icon")
    let railIcon = UIImage(named: "rail icon")
    
    var alert = UIAlertController(title: "Plan search", message: "",preferredStyle: .alert)
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        //Funkkarit.requestByAddress(address: textField.text!)
        searchPlan(address: textField.text!)
        
        //DispatchQueue.main.async {
        self.alert.dismiss(animated: false, completion: nil)
        //}
        textField.resignFirstResponder()
        return true
    }
    
    
    
    /*
     @IBAction func painaNappia(_ sender: UIButton) {
     
     let coords: (Double, Double) = Funkkarit.fetchYo()!
     print("aaaaaaaaaaa \(coords.0) \(coords.1)")
     
     Funkkarit.request(toLat: coords.0, toLon: coords.1)
     
     
     }*/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        self.mapView.isZoomEnabled = true;
        self.mapView.isScrollEnabled = true;
        self.mapView.isUserInteractionEnabled = true;
        self.mapView.showsUserLocation = true
        
        lastLocation = locations.last
        
        if (shit == false) {
            
            setRegion(location: lastLocation!, span1: 0.002, span2: 0.002)
        }
        
        shit = true
        
        
        
        
    }
    
    func setRegion(location: CLLocation, span1: Float, span2: Float) {
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(CLLocationDegrees(span1), CLLocationDegrees(span2))
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        mapView.setRegion(region, animated: true)
    }
    
    //@IBOutlet weak var text: UILabel!
    func searchPlan(address: String) {
        Funkkarit.requestByAddress(address: address, completion: { coords in
            print(coords)
            
            Funkkarit.requestPlan(fromLat: (self.lastLocation?.coordinate.latitude)!, fromLon: (self.lastLocation?.coordinate.longitude)!, toLat: coords.1, toLon: coords.0, completion: { iti in
                
                var loc: CLLocation = CLLocation()
                for var k in 0..<iti.count {
                    if let legs = iti[k]["legs"]! as? [[String: Any]] {
                        
                        
                        
                        let date = Date(timeIntervalSince1970: legs[k]["startTime"] as! TimeInterval)
                        let dateFormatter = DateFormatter()
                        
                        dateFormatter.locale = NSLocale.current
                        dateFormatter.dateFormat = "HH:mm"
                        let strDate = dateFormatter.string(from: date)
                        
                        
                        
                        //print("tassa ohjeet:")
                        print("reittiplani sulle")
                        self.planStr += ("Start moving \(strDate)\n")
                        //print("sun pitää lähtee liikkumaan klo \(strDate)")
                        var locAquired: Bool = false
                        for i in legs {
                            
                            if let mode = i["mode"] as? String {
                                //print("mode: \(i["mode"])")
                                if (mode == "WALK") {
                                    self.planStr += ("walk\n")
                                }
                                if (mode != "WALK") {
                                    if let from = i["from"] as? [String: Any],
                                        let stop = from["stop"] as? [String: Any] {
                                        
                                        if (locAquired == false) {
                                            loc = CLLocation(latitude: stop["lat"] as! CLLocationDegrees, longitude: stop["lon"] as! CLLocationDegrees)
                                            locAquired = true
                                        }
                                        
                                        if let stopName = stop["name"] as? String {
                                            
                                            //print("\(stopName): ")
                                            self.planStr += ("\(mode): \(stopName): ")
                                            
                                        }
                                    }
                                    
                                    if let trip = i["trip"] as? [String: Any],
                                        let route = trip["route"] as? [String: Any] {
                                        if let shortName = route["shortName"] as? String {
                                            //print(shortName)
                                            self.planStr += ("\(shortName)\n")
                                        }
                                    }
                                    
                                    
                                }
                            }
                        }
                        self.planStr += "destination"
                        print(self.planStr)
                        
                        
                    }
                }
                
                
                self.setRegion(location: loc, span1: 0.0005, span2: 0.0005)
                //kutsu että puskee pushin stringillä planStr
                AppDelegate().sendBus(data: self.planStr)
                
            }
            )
        }
        )
    }
    
    
    func search() {
        
        alert = UIAlertController(title: "Plan search", message: "",preferredStyle: .alert)
        
        let search = UIAlertAction(title: "Search", style: .default, handler: { (action) -> Void in
            
            let textField = self.alert.textFields![0]
            self.searchPlan(address: textField.text!)
            //DispatchQueue.main.async {
            self.alert.dismiss(animated: false, completion: nil)
            //}
        })
        
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Destination address"
            textField.clearButtonMode = .whileEditing
            textField.returnKeyType = UIReturnKeyType.search
            textField.delegate = self
        }
        
        
        alert.addAction(cancel)
        alert.addAction(search)
        
        present(alert, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //text.text = "Address \(currentAddress)"
        
        
        
        mapView.delegate = self
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        
        
        
        Funkkarit.requestStops(minLat: 60.217117, minLon: 24.798466, maxLat: 60.221634, maxLon: 24.819240, completion: { pyskit in
            //print(pyskit)
            
            
            
            if let data = pyskit["data"] as? [String: Any],
                let stops = data["stopsByBbox"] as? [[String: Any]] {
                
                
                for stop in stops {
                    var reitit: [Stop.Route] = []
                    var isRailMode: Bool = false
                    
                    if let s = stop["routes"] as? [[String: Any]] {
                        for stuff in s {
                            //print(stuff["shortName"] ?? "apua")
                            
                            let reitti = Stop.Route( mode: stuff["mode"] as! String, shortName: stuff["shortName"] as! String )
                            
                            if stuff["mode"] as? String == "RAIL" {
                                isRailMode = true
                            }
                            
                            reitit.append(reitti)
                            
                            
                        }
                    }
                    //print("\n\n\n")
                    
                    
                    let newStop = Stop(coordinate: CLLocationCoordinate2D(latitude: stop["lat"] as! CLLocationDegrees, longitude: stop["lon"] as! CLLocationDegrees), name: stop["name"] as! String, routes: reitit, mode: (isRailMode == true ? "RAIL" : "BUS"), id: stop["gtfsId"] as! String)
                    
                    //self.stopsNearby.append(newStop)
                    self.mapView.addAnnotation(newStop)
                    
                }
                
                //for stop in stopsNearby{
                
                //  mapView.addAnnotation(stop);
                //}
                
                
                
            }
        }
        )
        
        
    }
    
    var seppo: Bool = false
    func pressInfo(button: UIButton) {
        if (seppo == true) {
            let alertController = UIAlertController(title: selectedAnnotation?.title, message: "next departures\n" + (selectedAnnotation?.departures)!, preferredStyle: .alert)
            
            
            let cancel = UIAlertAction(title: "dismiss", style: .destructive, handler: { (action) -> Void in })
            let OKAction = UIAlertAction(title: "set as default", style: .default) {
                (action: UIAlertAction) in
                print("seivaa tieto")
                Funkkarit.saveDefaultStop(stop: (self.selectedAnnotation?.id)!)
            }
            alertController.addAction(OKAction)
            alertController.addAction(cancel)
            self.present(alertController, animated: false, completion: nil)
            
            seppo = false
        }
        
        
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? Stop
        //print("aukihehhe")
        
        
        Funkkarit.requestTimesByStop(stopId: (selectedAnnotation?.id)!, time: Int(NSDate().timeIntervalSince1970), deps: 2, completion: { stop in
            
            if let data = stop["data"] as? [String: Any],
                let stopp = data["stop"] as? [String: Any],
                let stopTimes = stopp["stoptimesForPatterns"] as?  NSArray{
                //print(stopTimes)
                
                var departures: String = ""
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
                self.selectedAnnotation?.departures = departures
                self.seppo = true
                
            }
            
        }
        )
        
        
        
        selectedAnnotation?.subtitle = selectedAnnotation?.routeShortNames()
        
        
        print(selectedAnnotation?.id)
        
        
    }
    
    
    
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView
        //guard let annotation = annotation as? Stop else {return nil}
        if let annotation = annotation as? Stop {
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) {
                //view = dequeuedView
                return view
            }else {
                
                if (annotation.mode == "BUS") {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.mode)
                    view.isEnabled = true
                    view.canShowCallout = true
                    
                    let button = UIButton(type: .detailDisclosure)
                    button.addTarget(self, action: #selector(pressInfo(button:)), for: .touchUpInside)
                    view.rightCalloutAccessoryView = button
                    
                    view.leftCalloutAccessoryView = UIImageView(image: busIcon)
                    view.image = stopPin
                    return view
                }
                if (annotation.mode == "RAIL"){
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.mode)
                    view.isEnabled = true
                    view.canShowCallout = true
                    
                    let button = UIButton(type: .detailDisclosure)
                    button.addTarget(self, action: #selector(pressInfo(button:)), for: .touchUpInside)
                    view.rightCalloutAccessoryView = button
                    
                    view.leftCalloutAccessoryView = UIImageView(image: railIcon)
                    view.image = railPin
                    return view
                }
            }
            
        }
        return nil
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        if (self.lastLocation != nil ) {
            
            
            setRegion(location: lastLocation!, span1: 0.002, span2: 0.002)
            
            
            
            
        }
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
}
