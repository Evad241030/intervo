//
//  ViewController.swift
//  intervo
//
//  Created by DAVID GONZALEZ on 3/16/17.
//  Copyright © 2017 David Gonzalez. All rights reserved.
//

// A. Make work when resigned to background.
// B. Set user defaults.

//FIX: Need to make fps selected affect calculation when countdown is paused. or before countdown starts.

//TOD0: Set inital frame to 1, or in the case of .5 to 2 since you should if you set your timer simultaneous to clicking your shutter, you start with at least 1 shot.

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    // If timer goes over 99 hours - timer resets back to 0.
    func timerDidReachMaxLimit() {
        if clockOne.seconds == 356400 {
            clockOne.seconds = 0
        }
    }
    
    func timerDidReachMinLimit() {
        if countdownMode.framesNeeded == 1 {
            countDownTimer.invalidate()
        }
    }
    
    func didFinishUpdatingSeconds(secondsNeeded: Int) {
        
        let secondsToFramesNeeded = shootInterval == 0 ? Int(Double(secondsNeeded) / shootIntervalHalf) : Int(Double(secondsNeeded) / Double(shootInterval))

        
        let numberWithCommas = NumberFormatter.localizedString(from: NSNumber(value: secondsToFramesNeeded), number: NumberFormatter.Style.decimal)
        
        framesShotLabel.text = ("\(numberWithCommas)")
        
    }
    
    func didFinishUpdatingFrames(framesNeeded: Int) {


            framesShotLabel.text = "\(framesNeeded)"

        
    }
    
    // MARK: - Timer vars
    var countUpTimer = Timer()
    var framesShot: Int = 0 {
        didSet {
            updateTimerClipLength()
        }
    }
    var startStopWatch: Bool = true
    var timerIsOn = false
    
    // This value is from Slider
    var shootInterval: Int = 1
    var shootIntervalHalf: Double = 0.5
    
    // Maybe Clear???
    var intervalCounter: Int = 0
//    var stopWatchString: String?
    var clockOne = ClockReadout()
    
    // MARK: - Countdown vars
    var countDownTimer = Timer()
    var countdownMode = Countdown()

    var reverse: Int = 0 {
        didSet {
           didReverse += 1
        }
    }
    var didReverse: Double = 0

    
    //FIX: - Mabe Clear FOR SURE
    var frameInterval: Int = 0
    var holdSecond: Int = 0
    // These variable hold seconds not minutes. I need to deconstruct these when used.
    var holdMinute: Int = 0
    var holdHour: Int = 0
    
    var startStopCountdown: Bool = false
    
    var newClipLength: Double = 0.0
    
    // MARK: Shared Global Vars
    var finalClipLength = ClockReadout()
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
            shootInterval = 0
            sliderLabel.text = "Shoot Interval: 0.5 seconds."
        } else if tempValue >= 1.0 {
            shootInterval = Int(tempValue)
            let displayString = shootInterval == 1 ? "\(shootInterval) second" : "\(shootInterval) seconds"
            sliderLabel.text = "Shoot Interval: \(displayString)."
        }

        
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
            countUpTimer.invalidate()
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
            countdownMode.isOn = false
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
            //CountdownMode.IsOn helps be disable Toggle()
            countdownMode.isOn = true
            didFinishUpdatingSeconds(secondsNeeded: countdownMode.secondsNeeded)
            disableToggle()
            
        } else {
            
            countDownTimer.invalidate()
            
            StartCountdown.setTitle("Start Countdown", for: UIControlState.normal)
            
            countdownMode.isOn = false
            
            startStopCountdown = true
            
            disableToggle()
        }
        
    }

    
    func updateCountdown() {
        /// OBVIOUSLY NEEDE TO RETHINK THIS
        frameInterval += 1


        // FRAMES Decrement based on frame interval and time
        
        // if .5 decrement by two
        if shootInterval < 1 {
            countdownMode.secondsNeeded -= 1
            didFinishUpdatingSeconds(secondsNeeded: countdownMode.secondsNeeded)
            frameInterval = 0
            updateCountDownLabels()
        } else if frameInterval == shootInterval {
            if countdownMode.secondsNeeded >= 1 {
                countdownMode.secondsNeeded -= 1
                didFinishUpdatingFrames(framesNeeded: countdownMode.secondsNeeded)
                frameInterval = 0

                updateCountDownLabels()
            }
        }
        
        //PUNTING - this is for my text fields
        clockOne.seconds += 1
        
        let secondsString = clockOne.seconds > 9 ? ":\(clockOne.seconds)" : ":0\(clockOne.seconds)"
        let minutesString = clockOne.minutes > 9 ? ":\(clockOne.minutes)" : ":0\(clockOne.minutes)"
        let hoursString = clockOne.hours > 9 ? ":\(clockOne.hours)" : ":0\(clockOne.hours)"
        
        timeSecond.text = secondsString
        timeMinute.text = minutesString
        timeHour.text = hoursString
        
        
        // based on seconds only....!!!!!

        
    }
    
        // This is for final Clip Length - going up - this is the bottom of the app
        // This is not elapsed time.
        func updateCountDownLabels() {
            
            reverse = countdownMode.framesNeeded
            
            // FIX:  I should use a protocol for this!!!!!
            let finalSeconds = didReverse / Double(fps)
            let finalMinutes = finalSeconds / 60.0
            let finalHours = finalMinutes / 60.0
            let remainderSeconds = Int(finalSeconds) - (Int(finalMinutes) * 60)
            let remainderMinutes = Int(finalMinutes) - ((Int(finalHours) * 60))
        
            
            if finalHours > 0.0, remainderMinutes < 10, remainderSeconds < 10 {
                let convertedHours = Int(finalHours)
                clipLengthLabel.text = convertedHours == 1 ?
                    "\(convertedHours) Hr. :0\(remainderMinutes) Min. :0\(remainderSeconds) Sec." :
                "\(convertedHours) Hrs., :0\(remainderMinutes) Min., :0\(remainderSeconds) Sec."
            } else if finalHours > 0.0, remainderMinutes < 10, remainderSeconds > 9 {
                let convertedHours = Int(finalHours)
                clipLengthLabel.text = convertedHours == 1 ?
                    "\(convertedHours) Hr. :0\(remainderMinutes) Min. :\(remainderSeconds) Sec." :
                "\(convertedHours) Hrs., :0\(remainderMinutes) Min., :\(remainderSeconds) Sec."
            } else if finalHours > 0.0, remainderMinutes > 9, remainderSeconds < 10 {
                let convertedHours = Int(finalHours)
                clipLengthLabel.text = convertedHours == 1 ?
                    "\(convertedHours) Hr. :\(remainderMinutes) Min. :0\(remainderSeconds) Sec." :
                "\(convertedHours) Hrs., :\(remainderMinutes) Min., :0\(remainderSeconds) Sec."
            } else if finalHours > 0.0, remainderMinutes > 9, remainderSeconds > 9 {
                let convertedHours = Int(finalHours)
                clipLengthLabel.text = convertedHours == 1 ?
                    "\(convertedHours) Hr. :\(remainderMinutes) Min. :\(remainderSeconds) Sec." :
                "\(convertedHours) Hrs., :\(remainderMinutes) Min., :\(remainderSeconds) Sec."
            } else if finalMinutes > 0.0, remainderSeconds < 10 {
                let convertedMinutes = Int(finalMinutes)
                clipLengthLabel.text = convertedMinutes < 10 ?
                    "0\(convertedMinutes) Min., :0\(remainderSeconds) Sec." :
                "\(convertedMinutes) Min., :0\(remainderSeconds) Sec."
            } else if finalMinutes > 0.0, remainderSeconds > 9 {
                let convertedMinutes = Int(finalMinutes)
                // I don't need to do a nil coalesce here
                clipLengthLabel.text = "\(convertedMinutes) Min., :0\(remainderSeconds) Sec."
            } else {
                let convertedSeconds = Int(finalSeconds)
                clipLengthLabel.text = convertedSeconds > 9 ?
                    ":\(convertedSeconds) Sec." :
                ":0\(convertedSeconds) Sec."
            }
            
        }
    
    // MARK: - TextField Delegate Methods
    
    // Clears out user's entry - but does not clear out previous number if app time is run first. This throws off evertyhing from then on.
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if countDownSwitch.isOn == false {
            return false
        } else {
            textField.clearsOnBeginEditing = true
            // For times when countdown is in progress - and I've re-entered into a text field
            if countdownMode.isOn == true {
                countDownTimer.invalidate()
                countdownMode.isOn = false
                startStopCountdown = true
                StartCountdown.setTitle("Countdown Paused", for: .normal)
            }
            
            if textField == timeSecond {
                countdownMode.framesNeeded = 0
                countdownMode.secondsNeeded = 0
                didFinishUpdatingSeconds(secondsNeeded: countdownMode.secondsNeeded)
            }
            
            if textField == timeMinute {
                var tempMinute: Int = 0
                if let minuteText = textField.text {
                    tempMinute = Int(minuteText)!
                    countdownMode.secondsNeeded -= tempMinute * 60
                    countdownMode.framesNeeded -= tempMinute * 60
            
                }
            }
            
            if textField == timeHour {
                var tempHour: Int = 0
                if let hourText = textField.text {
                    tempHour = Int(hourText)!
                    countdownMode.secondsNeeded -= (tempHour * 60) * 60
                    countdownMode.framesNeeded -= (tempHour * 60) * 60
   
                }
            }
            
            return true
            
        }
    }

    // This adds the user's new value for text field.
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        defer {
            if countdownMode.isOn == false {
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

            countdownMode.secondsNeeded += holdSecond
                
//                if shootInterval == 0 {
//                    countdownMode.framesNeeded += Int(Double(countdownMode.secondsNeeded) / 0.5 )
//                } else {
//                    countdownMode.framesNeeded += Int(countdownMode.secondsNeeded / shootInterval)
//                }

                didFinishUpdatingSeconds(secondsNeeded: countdownMode.secondsNeeded)
//                didFinishUpdatingFrames(framesNeeded: countdownMode.framesNeeded)
            }
            
        }
        
        if textField == timeMinute {
            
            if let minute = textField.text {
                holdMinute = Int(minute) ?? 0
//                countdownMode.framesNeeded += holdMinute
                countdownMode.secondsNeeded += holdMinute * 60
                timeSecond.text = "\(holdMinute)"
                didFinishUpdatingSeconds(secondsNeeded: countdownMode.secondsNeeded)
            }
            
        }
        
        if textField == timeHour {
            
            if let hour = textField.text {
                holdHour = Int(hour) ?? 0
//                countdownMode.framesNeeded += holdMinute
                countdownMode.secondsNeeded += (holdHour * 60) * 60
                timeHour.text = "\(holdHour)"
                didFinishUpdatingSeconds(secondsNeeded: countdownMode.secondsNeeded)
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
            countUpTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
            
            timerButton.setTitle("Pause Timer", for: UIControlState.normal)
            
            startStopWatch = false
            timerIsOn = true
            
            disableToggle()
            
        } else {
            countUpTimer.invalidate()
            
            
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
        
        timerDidReachMaxLimit()
        
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
            
            let numberWithCommas = NumberFormatter.localizedString(from: NSNumber(value: framesShot), number: NumberFormatter.Style.decimal)
            
//            framesShotLabel.text = "\(framesShot)"
            framesShotLabel.text = "\(numberWithCommas)"
            
            intervalCounter = 0
        } else if shootInterval == intervalCounter {
            framesShot += 1
            
            let numberWithCommas = NumberFormatter.localizedString(from: NSNumber(value: framesShot), number: NumberFormatter.Style.decimal)
            framesShotLabel.text = "\(numberWithCommas)"
//            framesShotLabel.text = "\(framesShot)"

            intervalCounter = 0
        }
        
    }

    // Updates estimated Final Clip Length For Timer/ Called when framesShot is set.
    func updateTimerClipLength() {
        
        // FIX: Need to safely unwrap this!
        let finalSeconds: Double = Double(framesShot) / Double(fps)
        let finalMinutes: Double = finalSeconds / 60
        let finalHours: Double  = finalMinutes / 60
        let remainderSeconds = (Int(finalSeconds) - (60 * Int(finalMinutes)))
        let remainderMinutes = (Int(finalMinutes) - (60 * Int(finalHours)))
        
        // FIX: Need to format these numbers to display correctly.
        if finalHours > 0.1, remainderMinutes < 10, remainderSeconds < 10 {
            let convertedHours = Int(finalHours)
            clipLengthLabel.text = convertedHours == 1 ?
                "\(convertedHours) Hr. :0\(remainderMinutes) Min. :0\(remainderSeconds) Sec." :
            "\(convertedHours) Hrs., :0\(remainderMinutes) Min., :0\(remainderSeconds) Sec."
        } else if finalHours > 0.1, remainderMinutes < 10, remainderSeconds > 9 {
            let convertedHours = Int(finalHours)
            clipLengthLabel.text = convertedHours == 1 ?
                "\(convertedHours) Hr. :0\(remainderMinutes) Min. :\(remainderSeconds) Sec." :
            "\(convertedHours) Hrs., :0\(remainderMinutes) Min., :\(remainderSeconds) Sec."
        } else if finalHours > 0.1, remainderMinutes > 9, remainderSeconds < 10 {
            let convertedHours = Int(finalHours)
                clipLengthLabel.text = convertedHours == 1 ?
                    "\(convertedHours) Hr. :\(remainderMinutes) Min. :0\(remainderSeconds) Sec." :
            "\(convertedHours) Hrs., :\(remainderMinutes) Min., :0\(remainderSeconds) Sec."
        } else if finalMinutes > 0.9, remainderSeconds < 10 {
            let convertedMinutes = Int(finalMinutes)
            clipLengthLabel.text = convertedMinutes < 10 ?
                ":0\(convertedMinutes) Min., :0\(remainderSeconds) Sec." :
            ":\(convertedMinutes) Min., :0\(remainderSeconds) Sec."
        } else if finalMinutes > 0.9, remainderSeconds > 9 {
            let convertedMinutes = Int(finalMinutes)
            // I don't need to do a nil coalesce here
            clipLengthLabel.text = ":\(convertedMinutes) Min., :\(remainderSeconds) Sec."
        } else {
            let convertedSeconds = Int(finalSeconds)
            clipLengthLabel.text = convertedSeconds > 9 ?
                ":\(convertedSeconds) Sec." :
            ":0\(convertedSeconds) Sec."
        }
            
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
        
        finalClipLength.minutes = 0
        finalClipLength.seconds = 0
        finalClipLength.hours = 0
        
        framesShot = 0
        countdownMode.framesNeeded = 0
        countdownMode.secondsNeeded = 0
        
        intervalCounter = 0
        
        framesShotLabel.text = "000"
        
        countdownMode.actualFramesShot = 0.0
        
        timeSecond.text = "00"
        timeMinute.text = "00"
        timeHour.text = "00"
        
        newClipLength = 0.0
        
        countdownMode.isOn = false
        
    }
    
    // Turn on or off any features when timer is running or when time is not running.
    func disableToggle() {
        
        if timerIsOn || countdownMode.isOn == true {
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

