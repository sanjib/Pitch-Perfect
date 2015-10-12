//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Sanjib Ahmad on 4/6/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var recordStatusLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    // helpful hints to users during various stages of recording
    let recordStartText = "Tap to record"
    let recordRecordingText = "Recording ..."
    let recordPauseText = "Paused"
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor(red: 193/255, green: 223/255, blue: 238/255, alpha: 1)
        
        // hide all the recording controls (resume, pause, stop) when view appears
        hideRecordingControls()
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        // helpful hint to user that recording is in progress
        recordStatusLabel.text = recordRecordingText
        
        // record button should be disabled during record
        recordButton.enabled = false
        
        // show all the recording controls (resume, pause, stop) during record
        showRecordingControls()
        
        // stop and pause buttons should be enabled during record
        stopButton.enabled = true
        pauseButton.enabled = true
        
        // resume button should be enabled only during pause
        resumeButton.enabled = false
        
        // record audio
        let dirPath = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask,
            true)[0] 
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime) + ".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)!
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            audioRecorder = try AVAudioRecorder(URL: filePath, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch _ {
        }
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        // helpful hint to user that recording is paused
        recordStatusLabel.text = recordPauseText
        audioRecorder.pause()
        
        // pause button disabled when recording is paused
        pauseButton.enabled = false
        
        // resume button is now enabled to continue recording
        resumeButton.enabled = true
    }
    
    @IBAction func resumeRecording(sender: UIButton) {
        recordStatusLabel.text = recordRecordingText
        audioRecorder.record()
        
        // resume button disabled once recording is resumed
        resumeButton.enabled = false
        
        // pause button enabled again
        pauseButton.enabled = true
    }
    
    
    @IBAction func stopRecordingAudio(sender: UIButton) {
        // set UI
        // record button should be disabled when recording is stopped
        recordButton.enabled = true
        recordStatusLabel.text = recordStartText
        
        // record controls (stop, pause, resume) should be hidden when recording is stopped
        hideRecordingControls()
        
        // stop recording audio
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch _ {
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            // save recorded audio
            recordedAudio = RecordedAudio(title: recorder.url.lastPathComponent!, filePath: recorder.url)
            
            // perform segue
            self.performSegueWithIdentifier("stopRecordingSegue", sender: recordedAudio)
        } else {
            recordStatusLabel.text = recordStartText
            recordButton.enabled = true
            hideRecordingControls()
        }
    }
    
    private func hideRecordingControls() {
        // hide all recording controls (stop, pause, record)
        stopButton.hidden = true
        pauseButton.hidden = true
        resumeButton.hidden = true
    }
    
    private func showRecordingControls() {
        // show all recording controls (stop, pause, record)
        stopButton.hidden = false
        pauseButton.hidden = false
        resumeButton.hidden = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecordingSegue" {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            playSoundsVC.receivedAudio = sender as! RecordedAudio
        }
    }
}

