//
//  ViewController.swift
//  intervo
//
//  Created by DAVID GONZALEZ on 3/16/17.
//  Copyright © 2017 David Gonzalez. All rights reserved.
//

//TODO: I could refactor estimated clip length to create a second instance of ClockReadout.

//TODO: I could branch out and make it so that You can enter desired clip length.

//TODO: I could created another branch to enter available time / And instead of counting time up - it counts down time.

//TODO: If all those things are going well, then I can try to make it so that Frames Shot allows for the user to enter.


import UIKit

class ViewController: UIViewController {

    var timer = Timer()
    var framesShot: Int = 0 {
        didSet {
            updateLabels()
        }
    }
    
    var timerIsOn = false
    var fps: Int = 24
    var shootInterval: Int = 1
    var intervalCounter: Int = 0
    var stopWatchString: String?
    var clockOne = ClockReadout()
    var startStopWatch: Bool = true

    
    @IBOutlet weak var fpsSegmentControl: UISegmentedControl!

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
    //FIX: BUG - Still display Shoot Interval is 0 seconds.
    //FIX: BUG - After working intially, readjusting values - counter won't work
    @IBAction func sliderMoved(_ sender: Any) {
        
        let tempValue = intervalSlider.value
        if tempValue == 0.0 {
            shootInterval = Int(Double(tempValue))
            sliderLabel.text = "Shoot Interval: 0.5 seconds."
        } else {
            shootInterval = Int(Double(tempValue))
            let displayString = shootInterval == 1 ? "\(shootInterval) second" : "\(shootInterval) seconds"
            sliderLabel.text = "Shoot Interval: \(displayString)."
        }
        
    }
    
    @IBOutlet weak var clipLengthLabel: UILabel!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var framesShotLabel: UILabel!
    //MARK: ClockReadout Label
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var intervalSlider: UISlider!
    
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

    func updateTimer() {

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
        
        updateFrames()
    }
    
    
    // Updates Frames Shot Label - Based on increment.
    //TODO: Need to factor in the value of Interval
    
    func updateFrames() {

        intervalCounter += 1
        
    
        if shootInterval < 1 {
            framesShot += 2
            framesShotLabel.text = "\(framesShot)"

        } else if intervalCounter == shootInterval {
            framesShot += 1
        framesShotLabel.text = "\(framesShot)"
            intervalCounter = 0
        }
        
    }

    
    func updateLabels() {
        
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
        // Do any additional setup after loading the view, typically from a nib.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

