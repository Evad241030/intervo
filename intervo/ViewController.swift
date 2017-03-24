//
//  ViewController.swift
//  intervo
//
//  Created by DAVID GONZALEZ on 3/16/17.
//  Copyright © 2017 David Gonzalez. All rights reserved.
//

// A. Make work when resigned to background.
// B. Set user defaults.
// C. Format Frames Counting with commas.

//FIX: Need to disable Segmented Control - as it does not change when the timer is stopped.
//FIX: Need to make fps selected affected calculation when countdown is paused. or before countdown starts.

//TOD0: Set inital frame to 1, or in the case of .5 to 2 since you should if you set your timer simultaneous to clicking your shutter, you start with at least 1 shot.

//TODO: I could refactor estimated clip length to create a second instance of ClockReadout.

//TODO: I could branch out and make it so that You can enter desired clip length.

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UpdateFramesLabelDelegate, TimeDidReachLimitDelegate {

    // MARK: Global Variables
    var delegate: UpdateFramesLabelDelegate?
    var limitDelegate: TimeDidReachLimitDelegate?
    // Shuts off timer if it goes ove 99 hours
    func TimerDidReachMaxLimit() {
        if clockOne.seconds == 356400 {
            timer.invalidate()
        }
    }
    
    func TimerDidReachMinLimit() {
        if framesNeeded == 1 {
            countDownTimer.invalidate()
        }
    }
    
    func didFinishUpdatingSeconds(secondsNeeded: Int) {
        
        // This allows me to pick 0 for my shoot interval - I allow it to replace it with 0.5
        
        if countDownSwitch.isOn == true {
            if shootInterval == 0 {
                framesNeeded = Int(Double(secondsNeeded) / 0.5)
            }
        }
        let updateShotLabel = shootInterval == 0 ? Int(Double(secondsNeeded) / 0.5) : Int(Double(secondsNeeded) / Double(shootInterval))

        framesShotLabel.text = ("\(updateShotLabel)")

    }
    
    func didFinishUpdatingFrames(framesNeeded: Int) {
        guard framesNeeded < 0 else {
            print("Test update frames delegate - seconds example \(framesNeeded)")
        framesShotLabel.text = "\(framesNeeded)"
            return
        }
    }
    
    // MARK: - Timer vars
    var timer = Timer()
    var framesShot: Int = 0 {
        didSet {
            updateTimerClipLength()
        }
    }
    var startStopWatch: Bool = true
    var timerIsOn = false
    
    // This value is from Slider
    var shootInterval: Int = 1
    
    // Maybe Clear???
    var intervalCounter: Int = 0
//    var stopWatchString: String?
    var clockOne = ClockReadout()
    
    // MARK: - Countdown vars
    var countDownTimer = Timer()
    var countdownIsOn = false
    var framesNeeded: Int = 0
    var secondsNeeded: Int = 0
//        {
//        didSet {
//            updateCountDownLabels()
//        }
//    }
    var actualFramesShot: Double = 0.0
    
    //FIX: - Mabe Clear FOR SURE
    var frameInterval: Int = 0
    var holdSecond: Int = 0
    // These variable hold seconds not minutes. I need to deconstruct these when used.
    var holdMinute: Int = 0
    var holdHour: Int = 0
    
    var startStopCountdown: Bool = false
    var countDownOne = ClockReadout()
    var newClipLength: Double = 0.0
    
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
            shootInterval = Int(tempValue)
            sliderLabel.text = "Shoot Interval: 0.5 seconds."
        } else if tempValue >= 1.0 {
            shootInterval = Int(tempValue)
            let displayString = shootInterval == 1 ? "\(shootInterval) second" : "\(shootInterval) seconds"
            sliderLabel.text = "Shoot Interval: \(displayString)."
        }
        
        didFinishUpdatingSeconds(secondsNeeded: secondsNeeded)
        
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var clipLengthLabel: UILabel!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var framesShotLabel: UILabel!
    @IBOutlet weak var frameStatusLabel: UILabel!
    
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
            frameStatusLabel.text = "Frames Needed"
            disableToggle()
        } else {
            startStopWatch = true
            timerButton.isEnabled = true
            StartCountdown.isEnabled = false
            cleanUp()
            startStopCountdown = false
            countDownTimer.invalidate()
            countdownIsOn = false
            frameStatusLabel.text = "Frames Shot"
            disableToggle()
        }
        
    }
    
    @IBOutlet weak var StartCountdown: UIButton!
    
    // MARK: - startCountdownHit
    
    @IBAction func startCountdownHit(_ sender: UIButton) {
        
        if startStopCountdown == true {
            countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateCountdown)), userInfo: nil, repeats: true)
            
            StartCountdown.setTitle("Pause Countdown", for: UIControlState.normal)
            
            startStopCountdown = false
            //CountdownIsOn helps be disable Toggle()
            countdownIsOn = true
            didFinishUpdatingSeconds(secondsNeeded: secondsNeeded)
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

        TimerDidReachMinLimit()
        
        
        // FRAMES Decrement based on frame interval and time
        
        // if .5 decrement by two 
        if shootInterval == 0 {
            framesNeeded -= 2
            didFinishUpdatingFrames(framesNeeded: framesNeeded)
            frameInterval = 0
            updateCountDownLabels()
        } else if frameInterval == shootInterval {
            if framesNeeded >= 1 {
                framesNeeded -= 1
                didFinishUpdatingFrames(framesNeeded: framesNeeded)
                frameInterval = 0
                updateCountDownLabels()
            }
        }
        
        // FIX: Time decrements - in real time... based on seconds only....!!!!!
        // THis is why minutes don't work yet. DO THIS!
        if holdSecond > 0 {
            holdSecond -= 1
            timeSecond.text = "\(holdSecond)"
        }
//        if holdMinute > 0 {
//            holdMinute -= 1
//            timeMinute.text = "\(holdMinute)"
//        }
//        
//        if holdHour > 0 {
//            holdSecond -= 1
//            timeHour.text = "\(holdHour)"
//        }
    }
    
        // This is for final Clip Length - going up -
        // This is not elapsed time.
        func updateCountDownLabels() {
            
            // FIX: CLEAR ACTUAL FRAMES SHOT
            actualFramesShot += 1.0
            
            // FIX:  I should use a protocol for this!!!!!
            let finalSeconds = actualFramesShot / Double(fps)
            let finalMinutes = finalSeconds / 60.0
            let finalHours = finalMinutes / 60.0
            let remainderSeconds = Int(finalSeconds) - (Int(finalMinutes) * 60)
            let remainderMinutes = Int(finalMinutes) - ((Int(finalHours) * 60) * 60)
            
            
            if finalSeconds < 60.0 {
                let messageString = Int(finalSeconds)
                clipLengthLabel.text = ":\(messageString) Sec."
            } else if finalMinutes < 60.0 {
                let messageString = Int(finalMinutes)
                clipLengthLabel.text = "\(messageString) Min., :\(remainderSeconds) Sec."
            } else {
                let messageString = Int(finalHours)
                clipLengthLabel.text = finalHours == 1 ? "\(messageString) Hr. :\(remainderMinutes) Min. :\(remainderSeconds) Sec." : "\(messageString) Hrs., :\(remainderMinutes) Min., :\(remainderSeconds) Sec."
            }
//            return
        }
        
    
    
    
    
    
    // MARK: - TextField Delegate Methods
    
    
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
                startStopCountdown = true
                StartCountdown.setTitle("Countdown Paused", for: .normal)
            }
            

            if textField == timeSecond {
                framesNeeded = 0
                secondsNeeded = 0
                didFinishUpdatingSeconds(secondsNeeded: secondsNeeded)
            }
            
            if textField == timeMinute {
                var tempMinute: Int = 0
                if let minuteText = textField.text {
                    tempMinute = Int(minuteText)!
                    secondsNeeded -= tempMinute * 60
                    framesNeeded -= tempMinute * 60
            
                }
            }
            
            if textField == timeHour {
                var tempHour: Int = 0
                if let hourText = textField.text {
                    tempHour = Int(hourText)!
                    secondsNeeded -= (tempHour * 60) * 60
                    framesNeeded -= (tempHour * 60) * 60
   
                }
            }
            
            return true
            
        }
    }

    // This adds the user's new value for text field.
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        defer {
            if countdownIsOn == false {
            StartCountdown.setTitle("Resume Countdown", for: .normal)

            }
        }
        
        // FIX: prevent more than 60 from being entered in text fields.
        // FIX: prevent user from leave text field blank.
        // This nil coalesing now prevents my crash... I still need to assing a 00 value for countown seconds - maybe this needs to fire off update labels. So it's a did set off of frames needed - with a call to update labels.
        
        //TODO: - NILLLY
        if textField == timeSecond {
    
            if let second = textField.text {
                holdSecond = Int(second) ?? 0
                print("I am hold second \(holdSecond)")
            secondsNeeded += holdSecond
                
                /// Can't do this divide is bad - especially if you're shoot interval is .5
                if shootInterval == 0 {
                    framesNeeded += Int(Double(secondsNeeded) / 0.5 )
                } else {
                    framesNeeded += Int(secondsNeeded / shootInterval)
                }
                
                
                
                print("\(framesNeeded) - Global Var")
            timeSecond.text = "\(holdSecond)"
                didFinishUpdatingSeconds(secondsNeeded: secondsNeeded)
                didFinishUpdatingFrames(framesNeeded: framesNeeded)
            }
            
        }
        
        if textField == timeMinute {
            
            if let minute = textField.text {
                holdMinute = Int(minute) ?? 0
                framesNeeded += holdMinute
                secondsNeeded += holdMinute * 60
                timeSecond.text = "\(holdMinute)"
                didFinishUpdatingSeconds(secondsNeeded: secondsNeeded)
            }
            
        }
        
        if textField == timeHour {
            
            if let hour = textField.text {
                holdHour = Int(hour) ?? 0
                framesNeeded += holdMinute
                secondsNeeded += (holdHour * 60) * 60
                timeHour.text = "\(holdHour)"
                didFinishUpdatingSeconds(secondsNeeded: secondsNeeded)
            }
        }
        
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

    // My main clock. Called by timer.
    func updateTimer() {
//FIX: Protect against going over 99 hours.
        clockOne.seconds += 1
        
        TimerDidReachMaxLimit()
        
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
    
    // Updates Frames Shot Label - Based on increment.
    // FIX: How do you set it to shoot initial frame - for example, if shoot interval is 5, does it shoot at 0 and 5, or just 5, 10, 15?
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

    // Updates estimated Final Clip Length For Both Timer and Countdown / Called when framesShot is set.
    func updateTimerClipLength() {
        
        // FIX: Need to safely unwrap this!
        let finalSeconds: Double = Double(framesShot) / Double(fps)
        let finalMinutes: Double = finalSeconds / 60
        let finalHours: Double  = finalMinutes / 60
        let remainderSeconds = (Int(finalSeconds) - (60 * Int(finalMinutes)))
        let remainderMinutes = (Int(finalMinutes) - (60 * Int(finalHours)))
        
        // FIX: Need to format these numbers to display correctly.
        if finalHours > 0.0, remainderMinutes < 10, remainderSeconds < 10 {
            let convertedHours = Int(finalHours)
            clipLengthLabel.text = convertedHours == 1 ? "\(convertedHours) Hr. :0\(remainderMinutes) Min. :0\(remainderSeconds) Sec." : "\(convertedHours) Hrs., :0\(remainderMinutes) Min., :0\(remainderSeconds) Sec."
        } else if finalHours > 0.0, remainderMinutes < 10, remainderSeconds > 9 {
            let convertedHours = Int(finalHours)
            clipLengthLabel.text = convertedHours == 1 ? "\(convertedHours) Hr. :0\(remainderMinutes) Min. :\(remainderSeconds) Sec." : "\(convertedHours) Hrs., :0\(remainderMinutes) Min., :\(remainderSeconds) Sec."
        } else if finalHours > 0.0, remainderMinutes > 9, remainderSeconds < 10 {
            let convertedHours = Int(finalHours)
                clipLengthLabel.text = convertedHours == 1 ? "\(convertedHours) Hr. :\(remainderMinutes) Min. :0\(remainderSeconds) Sec." : "\(convertedHours) Hrs., :\(remainderMinutes) Min., :0\(remainderSeconds) Sec."
        } else if finalMinutes > 0.0, remainderSeconds < 10 {
            let convertedMinutes = Int(finalMinutes)
            clipLengthLabel.text = convertedMinutes < 10 ? "0\(convertedMinutes) Min., :0\(remainderSeconds) Sec." : "\(convertedMinutes) Min., :0\(remainderSeconds) Sec."
        } else if finalMinutes > 0.0, remainderSeconds > 9 {
            let convertedMinutes = Int(finalMinutes)
            // I don't need to do a nil coalesce here
            clipLengthLabel.text = "\(convertedMinutes) Min., :0\(remainderSeconds) Sec."
        } else {
            let convertedSeconds = Int(finalSeconds)
            clipLengthLabel.text = convertedSeconds > 9 ? ":\(convertedSeconds) Sec." : ":0\(convertedSeconds) Sec."
        }
            
    }
//        if finalSeconds < 60.0 {
//            let convertedSeconds = Int(finalSeconds)
//            clipLengthLabel.text = convertedSeconds > 9 ? ":\(convertedSeconds) Sec." : ":0\(convertedSeconds) Sec."
//        } else if finalMinutes > 00.0, remainderSeconds < 10 {
//            let convertedMinutes = Int(finalMinutes)
//            clipLengthLabel.text = convertedMinutes < 10 ? "0\(convertedMinutes) Min., :0\(remainderSeconds) Sec." : "\(convertedMinutes) Min., :0\(remainderSeconds) Sec."
//        } else if finalMinutes > 0.0, remainderSeconds > 9 {
//            let convertedMinutes = Int(finalMinutes)
//            // I don't need to do a nil coalesce here
//            clipLengthLabel.text = convertedMinutes > 9 ? "\(convertedMinutes) Min., :\(remainderSeconds) Sec." : "\(convertedMinutes) Min., :0\(remainderSeconds) Sec."
//        } else if finalHours > 0.0, remainderMinutes < 10, remainderSeconds < 10 {
//            let convertedHours = Int(finalHours)
//            clipLengthLabel.text = convertedHours == 1 ? "\(convertedHours) Hr. :0\(remainderMinutes) Min. :0\(remainderSeconds) Sec." : "\(convertedHours) Hrs., :0\(remainderMinutes) Min., :0\(remainderSeconds) Sec."
//        } else if finalHours > 0.0, remainderMinutes < 10, remainderSeconds > 9 {
//            let convertedHours = Int(finalHours)
//            clipLengthLabel.text = convertedHours == 1 ? "\(convertedHours) Hr. :0\(remainderMinutes) Min. :\(remainderSeconds) Sec." : "\(convertedHours) Hrs., :0\(remainderMinutes) Min., :0\(remainderSeconds) Sec."
//        } else {
//            let convertedHours = Int(finalHours)
//            clipLengthLabel.text = convertedHours == 1 ? "\(convertedHours) Hr. :\(remainderMinutes) Min. :\(remainderSeconds) Sec." : "\(convertedHours) Hrs., :\(remainderMinutes) Min., :\(remainderSeconds) Sec."
//        }
//    }


    
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
        secondsNeeded = 0
        
        intervalCounter = 0
        
        framesShotLabel.text = "000"
        
        actualFramesShot = 0.0
        
        
        timeSecond.text = "00"
        timeMinute.text = "00"
        timeHour.text = "00"
        
        newClipLength = 0.0
        
        countdownIsOn = false
        
    }
    
    
    
    // Turn on or off any features when timer is running or when time is not running.
    func disableToggle() {
        
        if timerIsOn || countdownIsOn {
            intervalSlider.isEnabled = false
            quickClear.isEnabled = false
            fpsSegmentControl.isEnabled = false
        } else {
            intervalSlider.isEnabled = true
            quickClear.isEnabled = true
            fpsSegmentControl.isEnabled = true
        }
        
    }
    
//MARK : - DISMISS KEYBOARD
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        StartCountdown.setTitle("Resume Countdown", for: .normal)
    }
    
    
}

