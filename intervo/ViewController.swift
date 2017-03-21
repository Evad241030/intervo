//
//  ViewController.swift
//  intervo
//
//  Created by DAVID GONZALEZ on 3/16/17.
//  Copyright © 2017 David Gonzalez. All rights reserved.
//

// 1. When I set Estimated ClipLength (clipLength Priority) - I should get CountDown Timer, and show frames needed - May not want to do this after all - too much work.
// 2. How am I affecting Estimated Clip length when I dynamically change FPS - How do I know if I'm cross threads?
// 3. How do I set values to determine Shoot Interval?
// 4. Can this work when it is resigned to background?
// 5. Should I set user defaults - It would be nice for the user to always have a standard timelapse they want to start at and configure later.

//6. Format Frames Counting with commas.

//FIX: Need to disable Segmented Control - as it does not change when the timer is stopped.
//FIX: Need to make fps selected affected calculation when countdown is paused. or before countdown starts.

//TOD0: Set inital frame to 1, or in the case of .5 to 2 since you should if you set your timer simultaneous to clicking your shutter, you start with at least 1 shot.

//TODO: I could refactor estimated clip length to create a second instance of ClockReadout.

//TODO: I could branch out and make it so that You can enter desired clip length.

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
    
    // Maybe Clear???
    var intervalCounter: Int = 0
    var stopWatchString: String?
    var clockOne = ClockReadout()
    
    // MARK: - Countdown vars
    var countDownTimer = Timer()
    var countdownIsOn = false
    var framesNeeded: Int = 0 {
        didSet {
            updateCountDownLabels()
        }
    }
    
    //FIX: - Mabe Clear FOR SURE
    var frameInterval: Int = 0
    var holdSecond: Int = 0
    // These variable hold seconds not minutes. I need to deconstruct these when used.
    var holdMinute: Int = 0
    var holdHour: Int = 0
    
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

    
    @IBOutlet weak var intervalSlider: UISlider!
    
    @IBOutlet weak var countDownSwitch: UISwitch!
    
    
    
    //MARK: - Consider renaming this Start/Stop Button
    @IBOutlet weak var timerButton: UIButton!
    
    
    // MARK: TextField Outlets for Timer and Countdown.
    
    // 1. Seconds
    @IBOutlet weak var timeSecond: UITextField!
    @IBOutlet weak var timeMinute: UITextField!
    @IBOutlet weak var timeHour: UITextField!
    
    // MARK: - Start Countdown
    
    @IBAction func countDownSwitchHit(_ sender: UISwitch) {
        
        if countDownSwitch.isOn {
            timer.invalidate()
            timerIsOn = false
            cleanUp()
            timerButton.isEnabled = false
            StartCountdown.isEnabled = true
            startStopCountdown = true
        } else {
            startStopWatch = true
            timerButton.isEnabled = true
            StartCountdown.isEnabled = false
            cleanUp()
            startStopCountdown = false
            countDownTimer.invalidate()
            countdownIsOn = false
        }
        
    }
    
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
        
        frameInterval += 1
// FRAMES Decrement based on frame interval and time
        if frameInterval == shootInterval {
            if framesNeeded >= 1 {
                framesNeeded -= 1
                framesShotLabel.text = "\(framesNeeded)"
                frameInterval = 0
            } else {
                // TODO: Why do I invalidate count down timer here?
                countDownTimer.invalidate()
            }
            
        }
    
        // FIX: Time decrements - in real time... based on seconds only....!!!!!
        
        if holdSecond > 0 {
            holdSecond -= 1
            timeSecond.text = "\(holdSecond)"
        }
        
//        let x: Int = framesNeeded
//        
//        print("Estimate time Needed \(x)")
        
//        let secondsString = countDownOne.seconds > 9 ? "\(countDownOne.seconds)" : "0\(countDownOne.seconds)"
//        let minutesString = countDownOne.minutes > 9 ? "\(countDownOne.minutes)" : "0\(countDownOne.minutes)"
//        let hoursString = countDownOne.hours > 9 ? "\(countDownOne.hours)" : "0\(countDownOne.hours)"
//
//        timeSecond.text = secondsString
//        timeMinute.text = minutesString
//        timeHour.text = hoursString

//        stopWatchString = "\(hoursString):\(minutesString):\(secondsString)"

//        
//        updateFrames()

    }
    
    // MARK: - TextField Delegate Methods
    // This adds the user's new value for text field.
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if countdownIsOn == false {
            startStopCountdown = true
            countdownIsOn = true
            StartCountdown.setTitle("Resume Countdown", for: .normal)
        }
        
        // FIX: prevent more than 60 from being entered in text fields.
        // FIX: prevent user from leave text field blank.
        // This nil coalesing now prevents my crash... I still need to assing a 00 value for countown seconds - maybe this needs to fire off update labels. So it's a did set off of frames needed - with a call to update labels.
        
        //TODO: - NILLLY
        if textField == timeSecond {
    
            if let second = textField.text {
                holdSecond = Int(second) ?? 0
            framesNeeded += holdSecond / shootInterval
            timeSecond.text = "\(holdSecond)"
                framesShotLabel.text = "\(framesNeeded)"
                StartCountdown.setTitle("Resume Countdown", for: .normal)
            } else {
                timeSecond.text = "99"
            }
            
        }
        
        if textField == timeMinute {
            
            if let minute = textField.text {
                holdMinute = Int(minute) ?? 0
                framesNeeded += holdMinute * 60 / shootInterval
                framesShotLabel.text = "\(framesNeeded)"
                StartCountdown.setTitle("Resume Countdown", for: .normal)

            }
            
        }
        
        if textField == timeHour {
            
            if let hour = textField.text {
                holdHour = Int(hour) ?? 0
                framesNeeded += (holdHour * 60) * 60 / shootInterval
                framesShotLabel.text = "\(framesNeeded)"
                StartCountdown.setTitle("Resume Countdown", for: .normal)

            }
        }
        
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == timeHour {
            timeMinute.becomeFirstResponder()
        } else if textField == timeMinute {
            timeSecond.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        
        return true
    }
    
    // Clears out user's entry - but does not clear out previous number if app time is run first. This throws off evertyhing from then on.
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        if countDownSwitch.isOn == false {
            return false
        } else {
            
        textField.clearsOnBeginEditing = true

            // For times when countdown is in progress - and I've re-entered into a text field
            
        if countdownIsOn == true {
            countDownTimer.invalidate()
            countdownIsOn = false
            StartCountdown.setTitle("Countdown Paused", for: .normal)
        }

        // Instead of this - I should be pausing the countown by force....
//        if StartCountdown.titleLabel?.text == "Pause Countdown" {
//            StartCountdown.setTitle("Start Countdown", for: .normal)
//            startStopCountdown = true
//        }

            
        if textField == timeSecond {
            var tempSecond: Int = 0
            if let secondText = textField.text {
                tempSecond = Int(secondText) ?? 0
                framesNeeded -= tempSecond
//                framesShotLabel.text = "\(framesNeeded)"
            }
            
        }
        
        if textField == timeMinute {
            var tempMinute: Int = 0
            if let minuteText = textField.text {
                tempMinute = Int(minuteText) ?? 0
                framesNeeded -= tempMinute * 60
            }

//            framesShotLabel.text = "\(framesNeeded)"
        }
        
        if textField == timeHour {
            var tempHour: Int = 0
            if let hourText = textField.text {
                tempHour = Int(hourText) ?? 0
                framesNeeded -= (tempHour * 60) * 60
            }
//            framesShotLabel.text = "\(framesNeeded)"
        }
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

    // Need to calculate this for countdown
    func updateCountDownLabels() {
        return
//        let finalSeconds = framesShot / fps
//        let finalMinutes = finalSeconds / 60
//        let finalHours = finalMinutes / 60
//        let remainderSeconds = finalSeconds - (finalMinutes * 60)
//        let remainderMinutes = finalMinutes - (finalHours * 60)
//        
//        if finalSeconds < 60 {
//            let messageString = "\(finalSeconds) Sec."
//            clipLengthLabel.text = "\(messageString)"
//        } else if finalMinutes < 60 {
//            let messageString = "\(finalMinutes) Min., \(remainderSeconds) Sec."
//            clipLengthLabel.text = "\(messageString)"
//        } else {
//            let messageString = finalHours == 1 ? "\(finalHours) Hr, \(remainderMinutes) Min., \(remainderSeconds) Sec." : "\(finalHours) Hrs, \(remainderMinutes) Min., \(remainderSeconds) Sec."
//            clipLengthLabel.text = "\(messageString)"
//        }
        
    }
    
    
    
    // MARK: - QUICK CLEAR
    
    @IBOutlet weak var quickClear: UIButton!
    @IBAction func quickClearHit(_ sender: Any) {
        
        cleanUp()

        
    }
    
    func cleanUp() {
        
        clockOne.hours = 0
        clockOne.minutes = 0
        clockOne.seconds = 0
        
        clipLength.minutes = 0
        clipLength.seconds = 0
        clipLength.hours = 0
        
        framesShot = 0
        framesNeeded = 0
        
        framesShotLabel.text = "000"
        
        timeSecond.text = "00"
        timeMinute.text = "00"
        timeHour.text = "00"
        
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

