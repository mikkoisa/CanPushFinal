//
//  ViewControllerPref.swift
//  L7.1
//
//  Created by iosdev on 7.5.2017.
//  Copyright © 2017 stuff. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerPref: UIViewController {
    
    @IBOutlet weak var chooser: UISegmentedControl!
    
    override func viewDidLoad() {
        chooser.selectedSegmentIndex = getPref()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func valueChange(_ sender: Any) {
        switch chooser.selectedSegmentIndex
            
        {
        case 0:
            deleteData()
            save(pref: 0)
        case 1:
            deleteData()
            save(pref: 1)
        case 2:
            deleteData()
            save(pref: 2)
        default:
            break
        }
        
    }
    
    //MARK: Core data functions
    func save(pref: Int) {
        let contexti = AppDelegate().persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Preference", in: contexti)!
        let preference = NSManagedObject(entity: entity, insertInto: contexti)
        
        preference.setValue(pref, forKey: "pref" )
        
        do {
            try contexti.save()
            print("saved new preference!")
            // courses.append(course)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func getPref() -> Int {
        var preferences: [NSManagedObject] = []
        let contexti = AppDelegate().persistentContainer.viewContext
        var result: Int = 0
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Preference")
        
        do {
            preferences = try contexti.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        for preference in preferences {
            result = preference.value(forKey: "pref") as! Int
        }
        return result
    }
    
    func deleteData() -> Void {
        let contexti = AppDelegate().persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Preference")
        
        let result = try? contexti.fetch(fetchRequest)
        let resultData = result as! [Preference]
        
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
