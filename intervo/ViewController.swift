//
//  ViewController.swift
//  intervo
//
//  Created by DAVID GONZALEZ on 3/16/17.
//  Copyright © 2017 David Gonzalez. All rights reserved.
//



// MAIN PROBLEM! I NEED TO ZERO OUT VALUES ACCUMLATED WHEN TIMER IS INTIATED BEFORE I jump into countdown mode.

// 1. When I set Timer (Time Priority) It should convert to a countdown timer - I should see Frames Needed and Get Estimate Clip Length Calculate.
// 2. When I set Estimated ClipLength (clipLength Priority) - I should get CountDown Timer, and show frames needed
// 3. How am I affecting Estimated Clip length when I dynamically change FPS - How do I know if I'm cross threads?
// 4. How do I set values to determine Shoot Interval?
// 5. Can this work when it is resigned to background?
// 6. Should I set user defaults - It would be nice for the user to always have a standard timelapse they want to start at and configure later.
// 7. What if I did a countdown start button?
//8. Format Frames Counting with commas.

//FIX: Need to disable Segmented Control - as it does not change when the timer is stopped.

//TOD0: Set inital frame to 1, or in the case of .5 to 2 since you should if you set your timer simultaneous to clicking your shutter, you start with at least 1 shot.

//TODO: I could refactor estimated clip length to create a second instance of ClockReadout.

//TODO: I could branch out and make it so that You can enter desired clip length.

//TODO: I could created another branch to enter available time / And instead of counting time up - it counts down time.

//TODO: If all those things are going well, then I can try to make it so that Frames Shot allows for the user to enter.

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    // MARK: Global Variables
    
    // MARK: - Timer vars
    var timer = Timer()
    var framesShot: Int = 0 {
        didSet {
            updateLabels()
        }
    }
    var startStopWatch: Bool = true
    var timerIsOn = false
    var shootInterval: Int = 1
    var intervalCounter: Int = 0
    var stopWatchString: String?
    var clockOne = ClockReadout()
    
    // MARK: - Countdown vars
    var countDownTimer = Timer()
    var countdownIsOn = false
    var framesNeeded: Int = 0
    var startStopCountdown: Bool = false
    var countDownOne = ClockReadout()
    
    // MARK: Shared Global Vars
    var clipLength = ClockReadout()
    var fps: Int = 24
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        timeSecond.delegate = self
        timeMinute.delegate = self
        timeHour.delegate = self
        StartCountdown.isEnabled = false
        
        
    }
    
    // MARK: Slider controls
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
    
    @IBAction func sliderMoved(_ sender: Any) {

        let tempValue = intervalSlider.value
        
        if tempValue == 0.0 {
            shootInterval = Int(Double(tempValue))
            sliderLabel.text = "Shoot Interval: 0.5 seconds."
        } else if tempValue >= 1.0 {
            shootInterval = Int(Double(tempValue))
            let displayString = shootInterval == 1 ? "\(shootInterval) second" : "\(shootInterval) seconds"
            sliderLabel.text = "Shoot Interval: \(displayString)."
        }
        
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var clipLengthLabel: UILabel!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var framesShotLabel: UILabel!
    //MARK: ClockReadout Label
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var intervalSlider: UISlider!
    
    //MARK: - Consider renaming this Start/Stop Button
    @IBOutlet weak var timerButton: UIButton!
    
    
    // MARK: TextField Outlets for Timer and Countdown.
    
    // 1. Seconds
    @IBOutlet weak var timeSecond: UITextField!
    @IBOutlet weak var timeMinute: UITextField!
    @IBOutlet weak var timeHour: UITextField!
    
    // MARK: - Start Countdown
    
    @IBOutlet weak var StartCountdown: UIButton!
    
    @IBAction func startCountdownHit(_ sender: UIButton) {
        
        if startStopCountdown == true {
            countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateCountdown)), userInfo: nil, repeats: true)
            
            StartCountdown.setTitle("Pause Countdown", for: UIControlState.normal)
            
            startStopCountdown = false
            //CountdownIsOn helps be disable Toggle()
            countdownIsOn = true
            
            disableToggle()
            
        } else {
            
            countDownTimer.invalidate()
            
            StartCountdown.setTitle("Start Countdown", for: UIControlState.normal)
            
            countdownIsOn = false
            
            startStopCountdown = true
            
            disableToggle()
        }
        
    }

    
    func updateCountdown() {
        
//        clockOne.seconds += 1
//        
//        if clockOne.seconds == 60 {
//            clockOne.minutes += 1
//            clockOne.seconds = 0
//        }
//        
//        if clockOne.minutes == 60 {
//            clockOne.hours += 1
//            clockOne.minutes = 0
//        }
//        
//        let secondsString = clockOne.seconds > 9 ? "\(clockOne.seconds)" : "0\(clockOne.seconds)"
//        let minutesString = clockOne.minutes > 9 ? "\(clockOne.minutes)" : "0\(clockOne.minutes)"
//        let hoursString = clockOne.hours > 9 ? "\(clockOne.hours)" : "0\(clockOne.hours)"
//        
//        timeSecond.text = secondsString
//        timeMinute.text = minutesString
//        timeHour.text = hoursString
//        
//        
//        stopWatchString = "\(hoursString):\(minutesString):\(secondsString)"
//        timerLabel.text = stopWatchString
//        
//        updateFrames()
        
    }
    
    // MARK: - TextField Delegate Methods
    // This adds the user's new value for text field.
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        startStopCountdown = true
        
        // FIX: prevent more than 60 from being entered in text fields.
        // FIX: prevent user from leave text field blank.
        
        if textField == timeSecond {
            
            if let second = textField.text {
            framesNeeded += Int(second)! / shootInterval
            countDownOne.seconds += Int(second)!
            framesShotLabel.text = "\(framesNeeded)"
            }
            
        }
        
        if textField == timeMinute {
            if let minute = textField.text {
                let minutesInSeconds = Int(minute)! * 60
                framesNeeded += minutesInSeconds
                framesShotLabel.text = "\(framesNeeded)"
            }
            
        }
        
        if textField == timeHour {
            if let hour = textField.text {
                let hoursInSeconds = (Int(hour)! * 60) * 60
                framesNeeded += hoursInSeconds
                framesShotLabel.text = "\(framesNeeded)"
            }
        }
        
        
    }
    
    
    
    // Clears out user's entry - but does not clear out previous number if app time is run first. This throws off evertyhing from then on.
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        timer.invalidate()
        timerButton.setTitle("Start Timer", for: UIControlState.normal)
        startStopWatch = true
        timerIsOn = false
        countDownTimer.invalidate()
        timerButton.isEnabled = false
        StartCountdown.isEnabled = true
        textField.clearsOnBeginEditing = true
        
        if textField == timeSecond {
            let second = Int(textField.text!)!
            framesNeeded -= second
            framesShotLabel.text = "\(framesNeeded)"
        }
        
        if textField == timeMinute {
            let minute = Int(textField.text!)!
            let minutesInSeconds = minute * 60
            framesNeeded -= minutesInSeconds
            framesShotLabel.text = "\(framesNeeded)"
        }
        
        if textField == timeHour {
            let hour = Int(textField.text!)!
            let hoursInSeconds = (hour * 60) * 60
            framesNeeded -= hoursInSeconds
            framesShotLabel.text = "\(framesNeeded)"
        }
        
        return true
    }
    

    
    
    // Limits number that can be intered into text field.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterCountLimit = 2
        
        let startingLength = textField.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= characterCountLimit
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {

        
        return true
    }
    

    
    //This is the action version of my my StartStop Button. I didn't rename it to avoid the hassle.
    
    // MARK: - TIMER BUTTON!
    
    @IBAction func timerButtonHit(_ sender: Any) {
        
    if startStopWatch == true {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
            
            timerButton.setTitle("Pause Timer", for: UIControlState.normal)
            
            startStopWatch = false
            timerIsOn = true
            
            disableToggle()
            
        } else {
            timer.invalidate()
            
            
            timerButton.setTitle("Start Timer", for: UIControlState.normal)
            
            startStopWatch = true
            timerIsOn = false
            
            disableToggle()
        }
        
    }

    // This works with my main clock. Is called by timer.
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
        
        timeSecond.text = secondsString
        timeMinute.text = minutesString
        timeHour.text = hoursString
        
        
        stopWatchString = "\(hoursString):\(minutesString):\(secondsString)"
        timerLabel.text = stopWatchString
        
        updateFrames()
    }
    
    
//    func updateCountdown() {
//        if countDownFrames > 0 {
//        countDownFrames -= 1
//            framesShotLabel.text = ("\(countDownFrames)")
//        } else {
//            countDownTimer.invalidate()
//            timerButton.setTitle("Start Timer", for: UIControlState.normal)
//        }
//    }
    
    // Updates Frames Shot Label - Based on increment.
    func updateFrames() {

        intervalCounter += 1
        
    
        if shootInterval < 1 {
            framesShot += 2
            framesShotLabel.text = "\(framesShot)"
            intervalCounter = 0
        } else if shootInterval == intervalCounter {
            framesShot += 1
        framesShotLabel.text = "\(framesShot)"
            intervalCounter = 0
        }
        
    }

    // Updates estimated Clip Length / Called when framesShot is set.
    func updateLabels() {
        
        let finalSeconds = framesShot / fps
        let finalMinutes = finalSeconds / 60
        let finalHours = finalMinutes / 60
        let remainderSeconds = finalSeconds - (finalMinutes * 60)
        let remainderMinutes = finalMinutes - (finalHours * 60)
    
        if finalSeconds < 60 {
            let messageString = "\(finalSeconds) Sec."
            clipLengthLabel.text = "\(messageString)"
        } else if finalMinutes < 60 {
            let messageString = "\(finalMinutes) Min., \(remainderSeconds) Sec."
            clipLengthLabel.text = "\(messageString)"
        } else {
            let messageString = finalHours == 1 ? "\(finalHours) Hr, \(remainderMinutes) Min., \(remainderSeconds) Sec." : "\(finalHours) Hrs, \(remainderMinutes) Min., \(remainderSeconds) Sec."
            clipLengthLabel.text = "\(messageString)"
        }
        
    }

    // MARK: - QUICK CLEAR
    
    @IBOutlet weak var quickClear: UIButton!
    @IBAction func quickClearHit(_ sender: Any) {
        clockOne.hours = 0
        clockOne.minutes = 0
        clockOne.seconds = 0
        
        clipLength.minutes = 0
        clipLength.seconds = 0
        clipLength.hours = 0
        framesShot = 0
        
        timerLabel.text = "00:00:00"
        framesShotLabel.text = "000"
        timerButton.isEnabled = true
        StartCountdown.isEnabled = false
        
        timeSecond.text = "00"
        timeMinute.text = "00"
        timeMinute.text = "00"
        
        countdownIsOn = false
        
    }
    
    // Turn on or off any features when timer is running or when time is not running.
    func disableToggle() {
        
        if timerIsOn {
            intervalSlider.isEnabled = false
            quickClear.isEnabled = false
        } else {
            intervalSlider.isEnabled = true
            quickClear.isEnabled = true
        }
        
        if countdownIsOn {
            intervalSlider.isEnabled = false
            quickClear.isEnabled = false
        } else {
            intervalSlider.isEnabled = true
            quickClear.isEnabled = true
        }
        
    }
    
//MARK : - DISMISS KEYBOARD
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}

