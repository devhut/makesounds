//  SoundsTableViewController.swift
//  MakeSounds
//  Created by Dan Lopez on 6/15/15.
//  Copyright (c) 2015 DevHut. All rights reserved.

import UIKit

class SoundsTableViewController: UITableViewController {

    private var recordings : [String] = []
    
    // MARK: **** system calls ****
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        var anError: NSError?
        // this method returns an array of paths
        let dirPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        // so we get the first item in the array which is the correct path to our documents folder
        let docsDir = dirPaths[0] as! String
        
        
        
        //println("array of paths ----> \(docsDir)")
        
        /* we then use the path so we can see the contents of the folder, which will be the titles of the audio files we record. the optional casting assures that if there is an item in the array that is NOT a string, it will return nil. this is how we provide the "option". instead of crashing bc an item is not a string, we can "option" out. */
        
        let fileList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(docsDir, error: &anError) as? [String]
        // make sure there aren't any errors
        if anError != nil {
            println("there was an error trying to see the contents of directory ----> \(anError)")
        } else {
            // unwrap fileList bc it is an optional
            //println("no error! unwrapped constant ---> \(fileList)")
            if let aList = fileList {
                for aFile in aList {
                    recordings.append(aFile)
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: **** table view methods ****
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        cell.textLabel?.text = recordings[indexPath.row]
        
        return cell
    }
  
    // MARK: **** segues ****

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToPlayVC" {
            if let destinationVC = segue.destinationViewController as? PlayViewController {
                if let indexPath = tableView.indexPathForSelectedRow() {
                    destinationVC.fileName = recordings[indexPath.row]
                }
            }
        }// segueToPlayVC
        
        if segue.identifier == "segueToRecordVC" {
            if let destinationVC = segue.destinationViewController as? RecordViewController {
                destinationVC.delegate = self
            }
        }// segueToRecordVC
    }
    
}

// MARK: **** AudioFileAddedDelegate ****

extension SoundsTableViewController: AudioFileAddedDelegate {
    func newAudioFileAdded(aFileName: String) {
        println("the file name via delegation ------> \(aFileName)")
        recordings.append(aFileName)
        tableView.reloadData()
    }
}
