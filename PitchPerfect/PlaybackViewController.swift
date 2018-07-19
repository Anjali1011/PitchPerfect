//
//  PlaybackViewController.swift
//  PitchPerfect
//
//  Created by Anjali Kotnala on 05/04/18.
//  Copyright © 2018 Anjali Kotnala. All rights reserved.
//

import UIKit
import AVFoundation

class PlaybackViewController: UIViewController, AVAudioPlayerDelegate {
    var recordedFileURL : URL!
    @IBOutlet weak var rateSlowButton : UIButton!
    @IBOutlet weak var rateFastButton : UIButton!
    @IBOutlet weak var echoButton : UIButton!
    @IBOutlet weak var reverbButton : UIButton!
    @IBOutlet weak var pitchLowButton : UIButton!
    @IBOutlet weak var pitchHighButton : UIButton!
    @IBOutlet weak var stopButton : UIButton!
    var audioFile : AVAudioFile!
    var audioPlayerNode : AVAudioPlayerNode!
    var audioEngine : AVAudioEngine!
    var stopTimer :Timer!
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            audioFile = try AVAudioFile(forReading: recordedFileURL)
            
        }catch{
            print("Log audio file instance not created ")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("Log In func ViewWillAppear")
        rateSlowButton.imageView?.contentMode = .scaleAspectFit
        rateFastButton.imageView?.contentMode = .scaleAspectFit
        echoButton.imageView?.contentMode = .scaleAspectFit
        reverbButton.imageView?.contentMode = .scaleAspectFit
        pitchLowButton.imageView?.contentMode = .scaleAspectFit
        pitchHighButton.imageView?.contentMode = .scaleAspectFit
        stopButton.imageView?.contentMode = .scaleAspectFit
        configureUIWhenAudioPlaying(isPlaying:false)
    }


    // Function called when any playback button is pressed.
    @IBAction func PlayButtonPressed(sender:UIButton){
       configureUIWhenAudioPlaying(isPlaying:true)
        if let audioPlayerNode = audioPlayerNode{
            audioPlayerNode.stop()
            }
        switch(sender.tag){
        case 0 : playSound(rate:0.5)
        case 1 : playSound(rate:2)
        case 2 : playSound(echo:true)
        case 3 : playSound(reverb:true)
        case 4 : playSound(pitch:-1000)
        case 5 : playSound(pitch:1000)
        default : print("Log Nothing selected")
        }
    }
   
    // Function called when stop button is pressed.
    @IBAction func stopButtonPressed(sender:UIButton){
        if let audioPlayerNode = audioPlayerNode{
            audioPlayerNode.stop()
        }
        if let audioEngine = audioEngine{
            audioEngine.stop()
            audioEngine.reset()
        }
         configureUIWhenAudioPlaying(isPlaying:false)
    }
    

    // Function for sound playback with effects
    func playSound(rate:Float? = nil, pitch: Float? = nil, echo:Bool? = false, reverb:Bool? = false ){
        
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // Node for rate
        let rateNode = AVAudioUnitVarispeed()
        if let rate = rate{
            rateNode.rate = rate
            print("Log rate is : \(rate)")
            audioEngine.attach(rateNode)
        }
        else{
            print("Log rate is nil")
        }
        
        // Node for pitch
        let PitchNode =  AVAudioUnitTimePitch()
        if let pitch = pitch {
            PitchNode.pitch = pitch
            audioEngine.attach(PitchNode)
             print("Log pitch is : \(pitch)")
        }else{
            print("Log pitch is nil")
        }
        
        
        // Node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(AVAudioUnitDistortionPreset.multiEcho1)
        audioEngine.attach(echoNode)
        
        // Node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(AVAudioUnitReverbPreset.cathedral)
        audioEngine.attach(reverbNode)
        
        if rate != nil{
            connectAudioNodes(nodes:audioPlayerNode, rateNode, audioEngine.outputNode )
            }
        else if pitch != nil{
            connectAudioNodes(nodes:audioPlayerNode, PitchNode, audioEngine.outputNode )
        }
        else if echo == true{
            connectAudioNodes(nodes:audioPlayerNode, echoNode, audioEngine.outputNode )
        }
        else if reverb == true {
            connectAudioNodes(nodes:audioPlayerNode, reverbNode, audioEngine.outputNode )
        }
        
        
        
        do{
            try audioEngine.start()
        }catch{
            print("Log Cannot start the audio engine")
        }
     
//        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            print("In schedule file completion handler")
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
          //   schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(self.stopButtonPressed), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
            
        
        }
        audioPlayerNode.play()
    }
    
    // Function to connect the audio nodes
    func connectAudioNodes(nodes:AVAudioNode...){
            for x in 0..<nodes.count-1{
                audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
            }
        }
        
    
    // Delegate function called when audio playback finishes
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag{
            print("In delegate function")
            audioPlayerNode.stop()
            audioEngine.stop()
            configureUIWhenAudioPlaying(isPlaying: false)
        }else{
            print("Log audio did not finish")
        }
        
    }

    // Function to set up UI when audio is playing/not playing
    func configureUIWhenAudioPlaying(isPlaying:Bool){
        if isPlaying{
            rateSlowButton.isEnabled = false
            rateFastButton.isEnabled = false
            echoButton.isEnabled = false
            reverbButton.isEnabled = false
            pitchLowButton.isEnabled = false
            pitchHighButton.isEnabled = false
            stopButton.isEnabled = true
        }else{
            rateSlowButton.isEnabled = true
            rateFastButton.isEnabled = true
            echoButton.isEnabled = true
            reverbButton.isEnabled = true
            pitchLowButton.isEnabled = true
            pitchHighButton.isEnabled = true
            stopButton.isEnabled = false
        }
    }
    
    
}
