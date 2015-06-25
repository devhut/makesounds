//  Utility.swift
//  MakeSounds
//  Created by Dan Lopez on 6/17/15.
//  Copyright (c) 2015 DevHut. All rights reserved.

import UIKit
import AVFoundation

class Utility: NSObject {
   
    static let sharedUtility = Utility()
    var hasAudioPermission: Bool?
    private var aTimer: NSTimer?

    func checkAudioPermission() {
        var error: NSError?
        let audioSession = AVAudioSession.sharedInstance()
        let didSetCategory = audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error)
        
        if (error != nil) {
            println("error setting audio session category \(error)")
        } else {
            if didSetCategory {
                if audioSession.setActive(true, error: nil) {
                    audioSession.requestRecordPermission{[weak self](allowed: Bool) in
                        if allowed {
                            println("permission granted to record audio");
                            self!.hasAudioPermission = true
                        } else {
                            println("We don't have permission to record audio");
                            self!.hasAudioPermission = false
                        }
                    }
                } else {
                    println("could not activate audio session")
                }
            } else {
                println()
            }
        }
        
    }
    
    
    func documentsDirectoryPath() -> String {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        return docsDir
    }
    
    func createAudioPlayer(withFileName: String) -> AVAudioPlayer? {
        let soundFilePath = documentsDirectoryPath().stringByAppendingPathComponent(withFileName)
        // if there isn't a file name, we will have to handle the error gracefully
        var dataError: NSError?
        var playerError: NSError?
        let aPlayer: AVAudioPlayer?
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let fileData = NSData(contentsOfURL: soundFileURL!, options: NSDataReadingOptions.MappedRead, error: &dataError)
        if dataError != nil {
            println("error converting audio file to data ----> \(dataError)")
        } else {
            aPlayer = AVAudioPlayer(data: fileData, error: &playerError)
            if (playerError != nil) {
                println("error setting up our player! ----> \(playerError)")
            }
            return aPlayer
        }
        
        return nil
    }
    
    func createAudioRecroder(withFileName: String) -> AVAudioRecorder {
        let soundFilePath = documentsDirectoryPath().stringByAppendingPathComponent(withFileName)
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        var anError: NSError?
        let aRecorder = AVAudioRecorder(URL: soundFileURL, settings: audioRecordingSettings(), error: &anError)
        if (anError != nil) {
            println("there was an error allocing the recorder ---> \(anError)")
        }
        
        return aRecorder
    }
    
    func audioRecordingSettings() -> [NSObject : AnyObject] {
        
        /* Let's prepare the audio recorder options in the dictionary.
        Later we will use this dictionary to instantiate an audio
        recorder of type AVAudioRecorder */
        
        var audioSettings = [
            AVFormatIDKey : kAudioFormatMPEG4AAC as NSNumber,
            AVSampleRateKey : 16000.0 as NSNumber,
            AVNumberOfChannelsKey : 1 as NSNumber,
            AVEncoderAudioQualityKey : AVAudioQuality.Low.rawValue as NSNumber
        ]
        
        return audioSettings
    }

    func fireTimer(fire: Bool, forTarget: AnyObject, withSelector: Selector) {
        if fire {
            aTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: forTarget, selector: withSelector, userInfo: nil, repeats: true)
            println("timer still going???")
        } else {
            println("timer invalidated")
            aTimer?.invalidate()
            aTimer = nil
        }
    }

    func convertTime(time: NSTimeInterval) -> String {
        // 3600 seconds in an hour
        let duration = Int(time)
        var seconds = duration % 60
        var minutes = (duration / 60) % 60
        var hours = duration / 3600
        
        if duration <= 3600 {
            return String(format: "%d:%02d", minutes, seconds)
        }
        
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    
}
