//
//  ViewControllerMenu.swift
//  L7.1
//
//  Created by iosdev on 18.4.2017.
//  Copyright © 2017 stuff. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerMenu: UIViewController {
    
    @IBOutlet weak var texti: UILabel!
    var list = [String]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        request(location: "16435")
        self.texti.text = getMenu()
        
    }
    
    
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Get Lunch JSON from web
    func request(location: String) {
        let paeva = Date().description.components(separatedBy: "-")
        let dateString = paeva[0] + "/" + paeva[1] + "/" + paeva[2].components(separatedBy: " ")[0]
        print(location)
        //Http request
        let session = URLSession(configuration: URLSessionConfiguration.default)
        if let url = URL(string: "http://www.sodexo.fi/ruokalistat/output/daily_json/" + location + "/" + dateString + "/fi") {
            print (url)
            session .dataTask(with: url, completionHandler: {(data, response, error) in
                if error != nil {
                    print("\(error)")
                    
                    //Handle json data
                } else {
                    var i = 0
                    _ = try? JSONSerialization.jsonObject(with: data!)
                    if let json = try? JSONSerialization.jsonObject(with: data!) as! [String:Any] {
                        let courses = json["courses"] as! [[String:Any]]
                        
                        while i < courses.count {
                            self.list.append(courses[i]["title_en"]! as! String + "\n")
                            i += 1
                        }
                    }
                    //Save results
                    let result = self.list.joined(separator: "\n")
                    if self.list.isEmpty {
                        print("huhh")
                    } else {
                        DispatchQueue.main.async(execute: {
                            self.deleteCourses()
                            self.save(menu: result, id: 1)
                        })
                    }}
            }).resume()
        }
        //Show fetched lunch list
        DispatchQueue.main.async(execute: {
            self.texti?.text = self.getMenu()
        })
        
        
    }
    
    //MARK: - Core Data functions
    func save(menu: String, id: Int) {
        let contexti = AppDelegate().persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Course", in: contexti)!
        let course = NSManagedObject(entity: entity, insertInto: contexti)
        
        course.setValue(menu, forKey: "menu" )
        course.setValue(id, forKey: "id")
        
        do {
            try contexti.save()
            print("saved new!")
            // courses.append(course)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func deleteCourses() -> Void {
        let contexti = AppDelegate().persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Course")
        
        let result = try? contexti.fetch(fetchRequest)
        let resultData = result as! [Course]
        
        for object in resultData {
            contexti.delete(object)
        }
        
        do {
            try contexti.save()
            print("deleted old!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    // Core Data Fetch
    func getMenu() -> String {
        var courses: [NSManagedObject] = []
        var lister = [String]()
        let contexti = AppDelegate().persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Course")
        
        do {
            courses = try contexti.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        for course in courses {
            lister.append(course.value(forKey: "menu").unsafelyUnwrapped as! String)
        }
        
        let result = lister.joined(separator: "\n")
        return result
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
