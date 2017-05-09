//
//  HighscoreViewController.swift
//  sanicGame
//
//  Created by iosdev on 26.4.2017.
//  Copyright © 2017 iosdev. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import AVFoundation

class HighscoreViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    //variables & outlets
    var score: Int = 0
    var name: String = ""
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    @IBOutlet var myScore: UILabel!
    @IBOutlet var playerscores: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //inserts the player "stats" to database and saves the context
        let highscore:Highscore = NSEntityDescription.insertNewObject(forEntityName: "Highscore", into: DatabaseController.getContext()) as! Highscore
        highscore.player = "\(name)"
        highscore.score = Int32(score)
        DatabaseController.saveContext()
        
        //gets player "stats" from database sorted by decending score.
        let context = DatabaseController.getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Highscore")
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "score", ascending: false) ]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("fetchedResultsController.performFetch() failed")
        }
        
        myScore.text = "\(score)"
        playerscores.dataSource = self
        playerscores.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // Plays a silly soundclip after the view appears.
    override func viewDidAppear(_ animated: Bool) {
        sound()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //dipslays the player name and their score in the tableView cell's.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell")
        let player = (fetchedResultsController.object(at: indexPath) as! Highscore).player!.description
        let playerScore = (fetchedResultsController.object(at: indexPath) as! Highscore).score.description
        let combined = "\(player) : \(playerScore)"
        cell?.textLabel?.text = combined
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            print("numberOfRowsInSection")
            return 0
        }
        
        return sections[ section ].numberOfObjects
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (fetchedResultsController.sections?.count)!
    }
    
    //plays the Ring collection sound
    var soundPlayer:AVAudioPlayer?
    
    func sound(){
        guard let url = Bundle.main.url(forResource: "greenscreen-wow", withExtension: "mp3")else{
            print("Sound not playing")
            return
        }
        do{
            try!AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try!AVAudioSession.sharedInstance().setActive(true)
            soundPlayer = try!AVAudioPlayer.init(contentsOf: url, fileTypeHint: AVFileTypeMPEG4)
            soundPlayer!.play()
        }catch let error as NSError{
            print("error: \(error.localizedDescription)")
        }
    }
    
    
}
