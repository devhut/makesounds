//  PlayViewController.swift
//  MakeSounds
//  Created by Dan Lopez on 6/16/15.
//  Copyright (c) 2015 DevHut. All rights reserved.

import UIKit
import AVFoundation

class PlayViewController: UIViewController {

    var fileName: String?
    private let sharedUtility = Utility.sharedUtility
    private var audioPlayer: AVAudioPlayer?
    private let aSelector: Selector = "updateTimeLabels"
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeDurationLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    // MARK: **** System calls ****

    override func viewDidLoad() {
        super.viewDidLoad()
        let aFileName = fileName != nil ? fileName! : ""
        audioPlayer = sharedUtility.createAudioPlayer(aFileName)
        audioPlayer?.delegate = self
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

    func setPlayOrPauseText(p: String) {
        playAndPauseButton.setTitle(p, forState: UIControlState.Normal)
    }
    
    func updateTimeLabels() {
        let currentTime = audioPlayer?.currentTime != nil ? audioPlayer!.currentTime : 0.0
        currentTimeLabel.text = sharedUtility.convertTime(currentTime)
        let durationTime = audioPlayer?.duration != nil ? audioPlayer!.duration : 0.0
        timeDurationLabel.text = sharedUtility.convertTime(durationTime)
        println("updateTimeLabels called via timer ---> \(currentTime)")
    }

    // MARK: **** IBActions ****

    @IBAction func playOrPauseTapped(sender: AnyObject) {
        if audioPlayer?.playing == true {
            println("pause the player")
            setPlayOrPauseText("play")
            audioPlayer?.pause()
        } else {
            println("start playing")
            setPlayOrPauseText("pause")
            audioPlayer?.play()
            sharedUtility.fireTimer(true, forTarget: self, withSelector: aSelector)
        }
    }

    @IBAction func stopTapped(sender: AnyObject) {
        println("stop player!")
        setPlayOrPauseText("play")
        sharedUtility.fireTimer(false, forTarget: self, withSelector: aSelector)
        audioPlayer?.stop()
    }
    
}

// MARK: **** AVAudioPayerDelegate ****

extension PlayViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("PLAYER - DidFinishPlaying")
        sharedUtility.fireTimer(false, forTarget: self, withSelector: aSelector)
        playAndPauseButton.setTitle("play", forState: UIControlState.Normal)
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer!) {
        println("PLAYER - BeginInterruption")
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer!) {
        println("PLAYER - EndInterruption")
    }
    
}

