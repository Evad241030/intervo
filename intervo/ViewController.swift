//
//  ViewController.swift
//  intervo
//
//  Created by DAVID GONZALEZ on 3/16/17.
//  Copyright © 2017 David Gonzalez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var timer = Timer()
    var interval: Double = 0
    var framesShot: Int = 0
    var timerIsOn = false
    var clockOne = ClockReadout()

    // I'm thinking I'm might need this to increment.
    var fractions: Int = 0
    
    
    
    //TODO: Add Outlet for segment Control
    
    //TODO: Add Outlet for Slider
    // Set Slider to .5 second increment for if value is set to 0
    
    //TODO: Add Label Outet for Frames Counter
    
    //TODO: Add Outlet for Start Timer
    
    @IBOutlet weak var timerLabel: UILabel!
    
    
    @IBOutlet weak var timerButton: UIButton!
    
    
    //TODO: Add Action for Start Timer
    

    @IBAction func timerButtonHit(_ sender: Any) {
        
        if timerIsOn {

            timer.invalidate()
            timerButton.titleLabel?.text = "Stop"
            timerIsOn = false

        } else {
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
            timerIsOn = true
 
        }
        
    }

    //MARK: This updates my first clock readout.
    func updateTimer() {

        clockOne.seconds += 1
        timerLabel.text = ("test 00:00:\(clockOne.seconds)")
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

