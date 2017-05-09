//
//  Funkkarit.swift
//  reitti
//
//  Created by iosdev on 2.5.2017.
//  Copyright © 2017 org. All rights reserved.
//

import Foundation
import CoreData

class Funkkarit {
    static private let url = NSURL(string: "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql")!
    
    static func requestPlan(fromLat: Double, fromLon: Double, toLat: Double, toLon: Double, completion: @escaping ((_ itineraries: [[String: Any]]) -> Void)) {
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.addValue("application/graphql", forHTTPHeaderField: "Content-Type")
        let body:String = "{" + "\n" +
            "plan(" + "\n" +
            "from: {lat: \(fromLat),lon:\(fromLon)}" + "\n" +
            "to: {lat: \(toLat),lon:\(toLon)}" + "\n" +
            "numItineraries: 1" + "\n" +
            "modes: \"BUS,TRAM,RAIL,SUBWAY,FERRY,WALK\"" + "\n" +
            ") {" + "\n" +
            "itineraries {" + "\n" +
            "legs {" + "\n" +
            "startTime" + "\n" +
            "endTime" + "\n" +
            "mode" + "\n" +
            "from {" + "\n" +
            "stop {" + "\n" +
            "name" + "\n" +
            "lat" + "\n" +
            "lon" + "\n" +
            "}" + "\n" +
            "}" + "\n" +
            "trip {" + "\n" +
            "tripHeadsign" + "\n" +
            "route {" + "\n" +
            "shortName" + "\n" +
            "}" + "\n" +
            "}" + "\n" +
            "duration" + "\n" +
            "realTime" + "\n" +
            "distance" + "\n" +
            "transitLeg" + "\n" +
            "}" + "\n" +
            "}" + "\n" +
            "}" + "\n" +
        "}"
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                print(error?.localizedDescription ?? "dsxd")
                return
            }
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let daatta = json["data"] as? [String: Any],
                    let plan = daatta["plan"] as? [String: Any],
                    let iti = plan["itineraries"] as? [[String: Any]] {
                    //print(json)
                    
                    completion(iti)
                    
                    
                }
                
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
        
        
        
    }
    
    static func addressByCoords(lat: Double, lon: Double){
        
    }
    
    static func requestStops(minLat: Double, minLon: Double, maxLat: Double, maxLon: Double, completion: @escaping ((_ pyskit: [String: Any]) -> Void)) {
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.addValue("application/graphql", forHTTPHeaderField: "Content-Type")
        let body: String = "{" + "\n" +
            "stopsByBbox(minLat: \(minLat), minLon: \(minLon), maxLat: \(maxLat), maxLon: \(maxLon)) {" + "\n" +
            "lat," + "\n" +
            "lon," + "\n" +
            "name," + "\n" +
            "gtfsId," + "\n" +
            "routes {" + "\n" +
            "    mode," + "\n" +
            "    shortName" + "\n" +
            "}" + "\n" +
            "}" + "\n" +
        "}"
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){data,response,error in
            
            if error != nil{
                print(error?.localizedDescription ?? "dsxd")
                return
            }
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    //print(json)
                    completion(json)
                }
            }
            catch let error as NSError {
                print(error)
            }
        }
        
        task.resume()
        
    }
    
    //20170502
    static func requestTimesByStop(stopId: String, time: Int, deps: Int, completion: @escaping ((_ stop: [String: Any]) -> Void)) {
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.addValue("application/graphql", forHTTPHeaderField: "Content-Type")
        
        
        let body: String = "{" + "\n" +
            "stop(id: \"\(stopId)\"){" + "\n" +
            "    name" + "\n" +
            "    stoptimesForPatterns(startTime: \(time), timeRange: 3600, numberOfDepartures: \(deps)) {" + "\n" +
            "        pattern {" + "\n" +
            "            route {" + "\n" +
            "                shortName" + "\n" +
            "            }" + "\n" +
            "        }" + "\n" +
            "        stoptimes{" + "\n" +
            "            scheduledArrival," + "\n" +
            "            scheduledDeparture" + "\n" +
            "        }" + "\n" +
            "    }" + "\n" +
            "}" + "\n" +
        "}"
        
        //print(body)
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){data,response,error in
            
            if error != nil {
                print(error?.localizedDescription ?? "hehe")
                return
            }
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    //print(json)
                    completion(json)
                }
            }
            catch let error as NSError {
                print(error)
            }
        }
        
        task.resume()
        
        
    }
    
    
    static func requestByAddress(address: String, completion: @escaping ((_ coords: (Double,Double)) -> Void)){
        
        if case let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as String,
            let url = URL(string: "https://api.digitransit.fi/geocoding/v1/search?text=\(encodedAddress)&size=1") as URL! {
            //print("URLI!!!!!!!!!   \(url)")
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            
            
            let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
                if error != nil{
                    print(error?.localizedDescription ?? "dsxd")
                    return
                }
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        
                        if ((json["features"] as! NSArray).count > 0) {
                            //print(json["features"])
                            
                            if let daata = json["features"] as? [[String: Any]],
                                let geo = daata[0]["geometry"] as? [String: Any],
                                let coords = geo["coordinates"] as? NSArray{
                                //print(json)
                                let rCoords: (Double, Double) = (coords[0] as! Double, coords [1] as! Double)
                                
                                let context = AppDelegate().persistentContainer.viewContext
                                let entity = NSEntityDescription.entity(forEntityName: "Location", in: context)
                                
                                let lokeisson = NSManagedObject(entity: entity!,
                                                                insertInto: context)
                                
                                
                                lokeisson.setValue(coords[1], forKeyPath: "lat")
                                //print("coords1: \(coords[1])")
                                lokeisson.setValue(coords[0], forKeyPath: "lon")
                                //print("coords0: \(coords[0])")
                                
                                lokeisson.setValue(address, forKeyPath: "toAddress")
                                do {
                                    try context.save()
                                    print("saved!!!!!!")
                                    //print(fetchYo())
                                } catch let error as NSError {
                                    print("could not save. \(error)")
                                }
                                completion(rCoords)
                                
                            }
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    static func saveDefaultStop(stop: String) ->Bool{
        let context = AppDelegate().persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: context)
        
        let lokeisson = NSManagedObject(entity: entity!,
                                        insertInto: context)
        
        
        lokeisson.setValue(stop, forKeyPath: "defaultStop")
        
        do {
            try context.save()
            print("saved!!!!!!")
            //print(fetchYo())
            return true
        } catch let error as NSError {
            print("could not save. \(error)")
            return false
        }
        
    }
    static func fetchDefaultStop() -> String? {
        let moc = AppDelegate().persistentContainer.viewContext
        let fetchhh = NSFetchRequest<Location>(entityName: "Location")
        
        do {
            let fetched = try moc.fetch(fetchhh)
            
            
            return fetched.last?.defaultStop
        } catch {
            
            fatalError("failed to fetch: \(error)")
        }
        
    }
    
    
    static func saveDefaultStopData(stop: String) ->Bool{
        let context = AppDelegate().persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: context)
        
        let lokeisson = NSManagedObject(entity: entity!,
                                        insertInto: context)
        
        
        lokeisson.setValue(stop, forKeyPath: "defaultStopData")
        
        do {
            try context.save()
            print("saved defailt stop data!!!!!!")
            //print(fetchYo())
            return true
        } catch let error as NSError {
            print("could not save. \(error)")
            return false
        }
        
    }
    static func fetchDefaultStopData() -> String? {
        let moc = AppDelegate().persistentContainer.viewContext
        let fetchhh = NSFetchRequest<Location>(entityName: "Location")
        
        do {
            let fetched = try moc.fetch(fetchhh)
            
            print(fetched.last?.defaultStopData ?? "ei oo :(")
            return fetched.last?.defaultStopData
            
        } catch {
            
            fatalError("failed to fetch: \(error)")
        }
        
    }
    
    
    static func fetchYo() -> (Double, Double)?{
        
        let moc = AppDelegate().persistentContainer.viewContext
        let fetchhh = NSFetchRequest<Location>(entityName: "Location")
        
        
        do {
            let fetched = try moc.fetch(fetchhh)
            //print("lat \(fetched.first!.lat)")
            print(fetched.last!.toAddress ?? "oho")
            
            
            return (fetched.last!.lat, fetched.last!.lon)
            
            
            
            
        } catch {
            fatalError("failed to fetch: \(error)")
        }
    }
    
}
