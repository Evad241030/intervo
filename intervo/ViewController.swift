//
//  ViewController.swift
//  intervo
//
//  Created by DAVID GONZALEZ on 3/16/17.
//  Copyright © 2017 David Gonzalez. All rights reserved.
//

// 1. When I set Timer (Time Priority) It should convert to a countdown timer - I should see Frames Needed and Get Estimate Clip Length Calculate.
// 2. When I set Estimated ClipLength (clipLength Priority) - I should get CountDown Timer, and show frames needed
// 3. How am I affecting Estimated Clip length when I dynamically change FPS - How do I know if I'm cross threads?
// 4. How do I set values to determine Shoot Interval?
// 5. Can this work when it is resigned to background?
// 6. Should I set user defaults


//TODO: I could refactor estimated clip length to create a second instance of ClockReadout.

//TODO: I could branch out and make it so that You can enter desired clip length.

//TODO: I could created another branch to enter available time / And instead of counting time up - it counts down time.

//TODO: If all those things are going well, then I can try to make it so that Frames Shot allows for the user to enter.


import UIKit

class ViewController: UIViewController {

    var timer = Timer()
    var framesShot: Int = 0 {
        willSet {
            updateLabels()
        }
    }
    
    var timerIsOn = false
    var fps: Int = 24
    var shootInterval: Int = 1
    var intervalCounter: Int = 0
    var stopWatchString: String?
    var clockOne = ClockReadout()
    var clipLength = ClockReadout()
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
        
        clipLength.seconds = (framesShot / fps)
        clipLength.minutes = clipLength.seconds / 60
        clipLength.hours = clipLength.minutes / 60
        
        if clipLength.seconds == 60 {
            clipLength.minutes += 1
            clipLength.seconds = 0
        }
        
        if clipLength.minutes == 60 {
            clipLength.hours += 1
            clipLength.minutes = 0
        }
        
        let secondsString = clipLength.seconds > 9 ? "\(clipLength.seconds)" : "0\(clipLength.seconds)"
        let minutesString = clipLength.minutes > 9 ? "\(clipLength.minutes)" : "0\(clipLength.minutes)"
        let hoursString = clipLength.hours > 9 ? "\(clipLength.hours)" : "0\(clipLength.hours)"

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

