 //
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Sanjib Ahmad on 4/8/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var receivedAudio: RecordedAudio!
    var audioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // when the app is run on a device, the sound plays with a low volume on the front-speaker (receiver)
            // we want to play the sound instead on the bottom speaker, the following line is a fix for that
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch _ {
        }
        
        audioPlayer = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePath)
        audioPlayer.prepareToPlay()
        audioPlayer.enableRate = true
        
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePath)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(red: 221/255, green: 240/255, blue: 250/255, alpha: 1)
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudio(0.4)
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        playAudio(1.7)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-600)
    }
    
    @IBAction func playEchoAudio(sender: UIButton) {
        let audioUnitReverb = AVAudioUnitDistortion()
        audioUnitReverb.loadFactoryPreset(AVAudioUnitDistortionPreset.MultiEcho2)
        audioUnitReverb.preGain = -3
        audioUnitReverb.wetDryMix = 100
        playAudioWithSpecialEffects(audioUnitReverb)
    }
    
    @IBAction func playReverbAudio(sender: UIButton) {
        let audioUnitReverb = AVAudioUnitReverb()
        audioUnitReverb.loadFactoryPreset(AVAudioUnitReverbPreset.Plate)
        audioUnitReverb.wetDryMix = 75
        playAudioWithSpecialEffects(audioUnitReverb)
    }
    
    private func playAudioWithVariablePitch(pitch: Float) {
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        playAudioWithSpecialEffects(changePitchEffect)
    }
    
    private func playAudioWithSpecialEffects(audioUnit:AVAudioUnit) {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // code has been refactored here so that audioUnit can be set 
        // from other methods depending on the effect we want
        audioEngine.attachNode(audioUnit)
        
        audioEngine.connect(audioPlayerNode, to: audioUnit, format: nil)
        audioEngine.connect(audioUnit, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        do {
            try audioEngine.start()
//            try audioEngine.startAndReturnError()
        } catch _ {
        }
        
        audioPlayerNode.play()
    }
    
    private func playAudio(rate: Float) {
        audioPlayer.rate = rate
        audioPlayer.currentTime = 0.0
        audioPlayer.stop()
        // audioEngine is stopped to fix the sound overlap bug
        audioEngine.stop()
        audioPlayer.play()
    }

    @IBAction func stopAudio(sender: UIButton) {
        audioPlayer.stop()
        audioEngine.stop()
    }

}
