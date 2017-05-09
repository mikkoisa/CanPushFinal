//
//  ViewController.swift
//  sanicGame
//
//  Created by iosdev on 23.4.2017.
//  Copyright © 2017 iosdev. All rights reserved.
//

import UIKit
import AVFoundation

class GameController: UIViewController {
    @IBOutlet var counter: UILabel!
    @IBOutlet var sanicButton: UIButton!
    @IBOutlet var exit: UIButton!
    
    //Variables
    var rings: Int = 0
    var endScore = 0
    var givenName = "Testing"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    //This will pop an alert for the player to give a name
    override func viewDidAppear(_ animated: Bool) {
        if givenName == "Testing"{
            let alert = UIAlertController.init(title: "Naming", message: "Write your name!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField {(textField:UITextField) in
                textField.placeholder = "Your name..."
            }
            alert.addAction(UIAlertAction(title: "Submit", style: .default, handler:{ (action:UIAlertAction) in
                
                if let textField = alert.textFields?.first{
                    if textField.text == "" {
                        print("No name given!")
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        self.givenName = textField.text!
                    }
                }
            }))
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This moves the button up when pressed
    @IBAction func sanicAction(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations:{
            self.sanicButton.center.y+=150
        }, completion: nil)
        resetsanicButton()
        ringsCollected()
        sound()
    }
    //resets the game
    func resetSanicGame(){
        rings = 0
        counter.text = "\(rings)"
    }
    //simple counter for button presses, also updates the label displayed
    func ringsCollected(){
        rings = rings+1
        counter.text = "\(rings)"
    }
    //resets the button, called after the jump "animation"
    func resetsanicButton(){
        sanicButton.frame.origin = CGPoint(x:100,y:470)
    }
    //plays the Ring collection sound
    var soundPlayer:AVAudioPlayer?
    
    func sound(){
        guard let url = Bundle.main.url(forResource: "Ringsound", withExtension: "mp3")else{
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
    //moves the value of endScore and givenName to the next ViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        endScore = rings
        resetSanicGame()
        let segueName: String = segue.identifier!;
        if (segueName == "tohighscore") {
            let svc = segue.destination as! HighscoreViewController;
            svc.score = endScore
            svc.name = givenName
        }
        
    }
    
    
}


