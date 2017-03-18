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
    // no longer need this
//    var ticker = 0
    var framesShot: Int = 0 {
        didSet {
            updateLabels()
        }
    }
    
    var timerIsOn = false
    var fps: Int = 0
    // I'm setting my timerLabel.text to a string literal.
    var stopWatchString: String?
    var clockOne = ClockReadout()
    var startStopWatch: Bool = true
    // I'm thinking I'm might need this to increment.
    var fractions: Int = 0

    
    @IBOutlet weak var clipLengthLabel: UILabel!
    

    
    @IBOutlet weak var fpsSegmentControl: UISegmentedControl!
    //FIX: I need to set the initial value of selected segment index to something or else the app will crash. I'm currently hacking it, but selecting one - and jumping to another to initialize a value.
    @IBAction func changeFPS(_ sender: Any) {
        
        let fpsSelected = fpsSegmentControl.selectedSegmentIndex
        
        switch fpsSelected {
        case 0:
            fps = 24
            print("\(fps)")
        case 1:
            fps = 25
            print("\(fps)")
        case 2:
            fps = 30
            print("\(fps)")
        case 3:
            fps = 60
            print("\(fps)")
        case 4:
            fps = 120
            print("\(fps)")
        default:
            fps = 24
            print("\(fps)")
        }
    }
    
    
    //TODO: Add Outlet for Slider
    // TODO: Set Slider to .5 second increment for if value is set to 0
    @IBOutlet weak var intervalSlider: UISlider!
    
    
    @IBOutlet weak var framesShotLabel: UILabel!
    
    //MARK: ClockReadout Label
    @IBOutlet weak var timerLabel: UILabel!
    
    //MARK: -- Consider renaming this Start/Stop Button
    @IBOutlet weak var timerButton: UIButton!
    
    @IBAction func quickClearHit(_ sender: Any) {
        clockOne.hours = 0
        clockOne.minutes = 0
        clockOne.seconds = 0
        framesShot = 0
        timerLabel.text = "00:00:00"
        framesShotLabel.text = "000"
    }
    
    //This is the action version of my my StartStop Button. I didn't rename it to avoid the hassle.
    @IBAction func timerButtonHit(_ sender: Any) {
        
        if startStopWatch == true {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
            startStopWatch = false
            timerButton.setTitle("Stop Timer", for: UIControlState.normal)
            
        } else {
            timer.invalidate()
            timerButton.setTitle("Start Timer", for: UIControlState.normal)
            startStopWatch = true
        }
        
    }
//TODO: I want to add a "0" suffic for any time the second, minute, or hour is between 1-9... In the case of "blank" I want those to readout "00"
    //MARK: This updates my first clock readout.
    func updateTimer() {

        updateFrames()

        clockOne.seconds += 1

        
        if clockOne.seconds == 60 {
            clockOne.minutes += 1
            clockOne.seconds = 0
        }
        
        if clockOne.minutes == 60 {
            clockOne.hours += 1
            clockOne.minutes = 0
        }
    
        let secondsString = clockOne.seconds > 9 ? "\(clockOne.seconds)" : "0\(clockOne.seconds)"
        let minutesString = clockOne.minutes > 9 ? "\(clockOne.minutes)" : "0\(clockOne.minutes)"
        let hoursString = clockOne.hours > 9 ? "\(clockOne.hours)" : "0\(clockOne.hours)"
        
        stopWatchString = "\(hoursString):\(minutesString):\(secondsString)"
        timerLabel.text = stopWatchString
        
    }
    
    
    // Updates Frames Shot Label - Basedon increment.
    //TODO: Need to factor in the value of Interval
    
    func updateFrames() {
        
        framesShot += 1
        
        framesShotLabel.text = "\(framesShot)"
    
        
    }

    
    func updateLabels() {
        
        // This should be a computer property
        
        var seconds = (framesShot / fps)
        var minutes = seconds / 60
        var hours = minutes / 60
        
        if seconds == 60 {
            minutes += 1
            seconds = 0
        }
        
        if minutes == 60 {
            hours += 1
            minutes = 0
        }
        

        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let hoursString = hours > 9 ? "\(hours)" : "0\(hours)"

        clipLengthLabel.text = "\(hoursString):\(minutesString):\(secondsString)"

    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fpsSegmentControl.selectedSegmentIndex = 0
        // Do any additional setup after loading the view, typically from a nib.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

