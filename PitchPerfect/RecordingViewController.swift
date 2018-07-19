//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Anjali Kotnala on 04/04/18.
//  Copyright © 2018 Anjali Kotnala. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var startRecordButton : UIButton!
    @IBOutlet weak var stopRecordButton : UIButton!
    @IBOutlet weak var recordLabel : UILabel!
    
    var recorder : AVAudioRecorder!
    let session = AVAudioSession.sharedInstance()
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        startRecordButton.isEnabled = true
        stopRecordButton.isEnabled = false
        recordLabel.isEnabled = true
        recordLabel.text = "Tap to record"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func startRecordingBtnPressed(sender:AnyObject){
       print("Log startRecordingBtnPressed")
        
        recordLabel.text = "Recording in progress"
        startRecordButton.isEnabled = false
        stopRecordButton.isEnabled = true
        
        // Create the directory path
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        let recordedFileName = "RecordedVoice.wav"
        let completePath = directoryPath + "/" + recordedFileName
        let completePathURL = URL(fileURLWithPath: completePath)
        print("Log File path is \(completePathURL)")
        
        // Ask for recording permission
        session.requestRecordPermission { (granted : Bool) in
            if granted{
                do {try self.session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
                    }catch{
                    print("Log Cannot set category")
                }
                do{try self.session.setActive(true)
                }catch{
                    print("Log Cannot set session active")
                }
                
                
                do { try self.recorder = AVAudioRecorder(url: completePathURL, settings: [ : ])
                }catch{
                    print("Log cannot create recorder instance")
                }
                self.recorder.delegate = self
                self.recorder.isMeteringEnabled = true
                self.recorder.prepareToRecord()
                self.recorder.record()
            }else{
                print("Log : Recording permission is not granted")
            }
        }
        

    }
    // prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguetoplayback"{
            let playbackVC = segue.destination as!  PlaybackViewController
            playbackVC.recordedFileURL = recorder.url
            
            
        }
    }
   
    // Delegate function called after recorfing is finished
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag{
        print("Log Recording finished")
        performSegue(withIdentifier: "seguetoplayback", sender: recorder.url)
        }
        else{
            print("Log recording is not successful")
        }
        
    }
    
    // Function called when stop button is pressed.
    @IBAction func stopRecordingBtnPressed(sender:AnyObject){
        print("Log stopRecordingBtnPressed")
        recordLabel.text = "Recording stopped."
        startRecordButton.isEnabled = true
        stopRecordButton.isEnabled = false
        recorder.stop()
        do {
            try session.setActive(false)
        }
        catch {
            print("Log cannot disable the session")
        }

}

}
