//
//  OutsideViewController.swift
//  local2
//
//  Created by Aaron Mann on 1/11/17.
//  Copyright © 2017 Aaron Mann. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class OutsideViewController: UIViewController, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var previewView: UIView!
    let lm = CLLocationManager()

    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var longitude : Double = 0.0
    var latitude : Double = 0.0
    var heading_ : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.requestWhenInUseAuthorization()
        lm.startUpdatingLocation()
        lm.startUpdatingHeading()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //print("heading", newHeading.magneticHeading)
        heading_ = newHeading.magneticHeading
        //print(manager.location?.coordinate.latitude)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitude = locations[locations.count-1].coordinate.latitude
        longitude = locations[locations.count-1].coordinate.longitude
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = previewView.bounds
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //lm.desiredAccuracy = kCLLocationAccuracyBest
        
        //while lm.location?.horizontalAccuracy > 10 {
        
        
        //}
        
        lm.stopUpdatingHeading()
        lm.stopUpdatingLocation()

        
        if segue.identifier == "arSegue"
        {
            if let destination = segue.destination as? AugmentedViewController
            {
                destination.heading = heading_
                destination.lat = latitude
                destination.long = longitude
            }
        }
        
        
        if segue.identifier == "createSegue"
        {
            if let destination = segue.destination as? CreateViewController
            {
                destination.heading = heading_
                destination.lat = latitude
                destination.long = longitude
            }
        }
        
        
    }
    
    
    
    
    
}
