//  RecordViewController.swift
//  MakeSounds
//  Created by Dan Lopez on 6/15/15.
//  Copyright (c) 2015 DevHut. All rights reserved.

import UIKit
import AVFoundation

/* The shared audio session object acts as an intermediary between your app and the system’s media services,
providing access to the devices audio hardware. The device's media system services all other apps as well,
and the requests they make for media service might have a higher priority i.e. phone calls.
Your app does not directly control certain audio settings; instead, you request preferred values for these settings and
observe properties on the AVAudioSession singleton object (or related port and data source objects)
to see whether, when, and to what extent your requests take effect.*/

protocol AudioFileAddedDelegate {
    func newAudioFileAdded(aFileName: String)
}

class RecordViewController: UIViewController {
    
    var delegate: AudioFileAddedDelegate?
    private var recordingFileName: String?
    private var audioRecorder: AVAudioRecorder?
    private let sharedUtility = Utility.sharedUtility
    private let aSelector: Selector = "updateTimeLabel"
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var shhLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    // MARK: **** System calls ****

    override func viewDidLoad() {
        super.viewDidLoad()
        // make the record button round
        recordButton.layer.masksToBounds = true
        // to make a round button, make the button a perfect square in IB, then divide it by 2 in code
        recordButton.layer.cornerRadius = 50.0
        // configure the UI upon loading
        setUIForRecording(false)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        sharedUtility.fireTimer(false, forTarget: self, withSelector: aSelector)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: **** UI Configuration ****
    
    func setUIForRecording(set: Bool) {
        if set {
            shhLabel.hidden = false
            doneButton.hidden = false
            titleTextField.userInteractionEnabled = false
            enableRecordButton(true)
        } else {
            shhLabel.hidden = true
            doneButton.hidden = true
            titleTextField.userInteractionEnabled = true
            self.recordButton.setTitle("record", forState: UIControlState.Normal)
            enableRecordButton(false)
        }
    }
    
    func enableRecordButton(enable: Bool) {
        if enable {
            recordButton.userInteractionEnabled = true
            recordButton.backgroundColor = UIColor(red: 255.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0)
        } else {
            recordButton.userInteractionEnabled = false
            recordButton.backgroundColor = UIColor.lightGrayColor()
        }
    }

    @IBAction func recordOrPauseTapped(sender: UIButton) {
        
        if let recorder = audioRecorder {
            println("audio recorder was NOT nil")
        } else {
            recordingFileName = titleTextField.text + ".m4a"
            audioRecorder = sharedUtility.createAudioRecroder(recordingFileName!)
            audioRecorder!.delegate = self
            audioRecorder!.prepareToRecord()
        }
        
        titleTextField.hasText() ? titleTextField.endEditing(true) : titleTextField.endEditing(false)
        setUIForRecording(true)

        if audioRecorder?.recording == true {
            println("pause recording")
            self.recordButton.setTitle("continue...", forState: UIControlState.Normal)
            audioRecorder?.pause()
        } else {
            println("start recording")
            self.recordButton.setTitle("pause", forState: UIControlState.Normal)
            sharedUtility.fireTimer(true, forTarget: self, withSelector: aSelector)
            audioRecorder?.record()
        }
        
    }
    
    // MARK: **** IBActions ****

    @IBAction func doneTapped(sender: UIButton) {
        // configure UI
        setUIForRecording(false)
        // stop the timer
        sharedUtility.fireTimer(false, forTarget: self, withSelector: aSelector)
        // ends the recording and closes the file
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    /* A little bit of validation - if the text field does not have any text, we will not allow recording.
    This action will detect text */
    @IBAction func userDidEditTitle(sender: AnyObject) {
        if titleTextField.hasText() {
            enableRecordButton(true)
        } else {
            enableRecordButton(false)
        }
    }
    
    func updateTimeLabel() {
        let currentTime = audioRecorder?.currentTime != nil ? audioRecorder!.currentTime : 0.0
        currentTimeLabel.text = sharedUtility.convertTime(currentTime)
        println("updateTimeLabel called via timer ---> \(currentTime)")
    }
}

// MARK: **** AVAudioRecorderDelegate ****

extension RecordViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        println("RECORDER - DidFinishRecording")
        sharedUtility.fireTimer(false, forTarget: self, withSelector: aSelector)
        delegate?.newAudioFileAdded(recordingFileName!)
        titleTextField.text = ""
    }
    
    func audioRecorderBeginInterruption(recorder: AVAudioRecorder!) {
        println("RECORDER - BeginInterruption")
    }
    
    func audioRecorderEndInterruption(recorder: AVAudioRecorder!) {
        println("RECORDER - EndInterruption")
    }
    
}

// MARK: **** UITextFieldDelegate ****

extension RecordViewController: UITextFieldDelegate {
    // dismiss the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        titleTextField.endEditing(true)
        return true
    }
    
}
