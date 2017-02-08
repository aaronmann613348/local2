//
//  AugmentedViewController.swift
//  local2
//
//  Created by Aaron Mann on 1/11/17.
//  Copyright © 2017 Aaron Mann. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase
import CoreLocation
import CoreMotion



class AugmentedViewController: UIViewController, CLLocationManagerDelegate {
    
    let rootRef = FIRDatabase.database().reference().child("Texts").ref
    
    var long : Double = 0.0 //sent from other controller
    var lat : Double = 0.0 //sent from other controller
    var heading : Double = 0.0
    var type_ : Int = 0
    
    var acc_x : [Double] = []
    var acc_z : [Double] = []
    var acc_y : [Double] = []
    
    var xPos : CGFloat = 150
    var curr_xPos : CGFloat = 150
    var curr_yPos : CGFloat = 350

    var yPos : CGFloat = 350
    
    var message_top : String = "Hello Darkness"
    
    var temp_height : Int = 0
    
    var text : Placed?

    var fetch_flag : Bool = false
    var h_flag : Bool = true
    
    var last_pitch : Double = 90.0
    var acc_z_curr : Double = 0.0
    var distances : [Double] = []
    
    
    var currScale : CGFloat = 1.0
    
    var x_diff : Double = 0.0
    var y_diff : Double = 0.0
    
    var acc_y_avg : Double = 75.0
    
    let tf = UITextField()
    
    let overLay = UIImageView()
    
    let lm = CLLocationManager()
    var angle : Double = 0.0
    
    var motionManager = CMMotionManager()
    
    var texts = [Placed]()
    var final_text : Placed?
    
    @IBOutlet weak var augmentedView: UIView!

    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var augmentedLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetch()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.requestWhenInUseAuthorization()
        lm.startUpdatingHeading()
        lm.startUpdatingLocation()
        
        motionManager.accelerometerUpdateInterval = 0.025
        motionManager.deviceMotionUpdateInterval = 0.025

        start_accel()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //the camera view and subviews
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
                
                augmentedLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                augmentedLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                augmentedLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                augmentedView.layer.addSublayer(augmentedLayer!)
                
                captureSession!.startRunning()
                
                var temp_scale = 36.699
                if fetch_flag == true {
                    if distances[0] > 10 {
                        temp_scale = temp_scale*10/distances[0]
                    }
                }
                curr_yPos = yPos + CGFloat(temp_scale*Double(temp_height) * -1)
                
                
                tf.frame = CGRect(x: xPos, y: curr_yPos, width: 150, height: 40)
                tf.backgroundColor = UIColor.clear
                tf.text = String(describing: message_top)
                
                overLayer()
                overLay.frame = CGRect(x: xPos, y: curr_yPos - 40, width: 50, height: 50)
                self.view.addSubview(tf)
                self.view.addSubview(overLay)
                
            }
        }
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        augmentedLayer!.frame = augmentedView.bounds
    }
    
    
    func start_accel() {
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            self.outputAccData_(accelerometerData!.acceleration)
            //self.start.setTitle("Stop", for: UIControlState())
            if(NSError != nil) {
                print("\(NSError)")
            }
        }
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {
            (deviceMotion, error) -> Void in
            self.outputRotationData(deviceMotion!)
            if(error != nil){
                print("\(error)")
            }
        })

    }
    
    
    //saves accel in z direction
    func outputAccData_(_ acceleration: CMAcceleration){
        acc_z_curr = acceleration.z
        
        acc_x.append(acceleration.x)
        acc_y.append(acceleration.y)
        acc_z.append(acceleration.z)
        

    }
    
    //adjusts the y position based on angle to the ground
    func y_angle_adjust(pitch_: Double, acc_z_: Double){
        
        let frame = augmentedView.frame.height/2
        var total_frame = sin(36.5*M_PI/180)
        total_frame = 1.0/total_frame
        total_frame = total_frame*Double(frame)
        
        //var curr_hangle = atan(temp_height)
        
        //let angle_to_person = atan(Double(temp_height)/distances[1])*180/M_PI
        
        var diff = 0.0
        
        var angle_object = 0.0
        
        if temp_height != 0 {
            angle_object = atan(Double(temp_height)/distances[0])*180/M_PI
        }
        if acc_z_ >= 0 {
            let above = 90 - pitch_
            diff = above - angle_object
            /*print("angle of object", angle_object)
            print("above", above)
            print("diff", diff)*/

            
            if  diff >= 0 && diff < 37 {
                //print("here 4")
                curr_yPos = 350 + CGFloat(total_frame)*CGFloat(sin(diff*M_PI/180))
                tf.frame = CGRect(x: curr_xPos, y: curr_yPos, width: currScale*150, height: currScale*40) //approachs from bottom
                overLay.frame = CGRect(x: curr_xPos, y: curr_yPos - 40, width: currScale*50, height: currScale*50)
            }
                
            else if diff > -37 && diff < 0 {
                //print("here 5")
                curr_yPos = 350 - CGFloat(total_frame)*CGFloat(sin(diff*M_PI/180))
                tf.frame = CGRect(x: curr_xPos, y: curr_yPos, width: currScale*150, height: currScale*40) //approachs from top
                overLay.frame = CGRect(x: curr_xPos, y: curr_yPos - 40, width: currScale*50, height: currScale*50)
            
            }
            
            else {
                //print("here 6")
                curr_yPos = 700
                tf.frame = CGRect(x: curr_xPos, y: curr_yPos, width: currScale*150, height: currScale*40)
                overLay.frame = CGRect(x: curr_xPos, y: curr_yPos - 40, width: currScale*50, height: currScale*50)
            }
        }
        
        else {
            let below = 90 - pitch_
            diff = below + angle_object

            /*print("angle of object", angle_object)
            print("below", below)
            print("diff", diff)*/

            if  diff > -37 && diff < 0 {
                //print("here 7")
                curr_yPos = 350 + CGFloat(total_frame)*CGFloat(sin(diff*M_PI/180))
                tf.frame = CGRect(x: curr_xPos, y: curr_yPos, width: currScale*150, height: currScale*40) //approachs from top
                overLay.frame = CGRect(x: curr_xPos, y: curr_yPos - 40, width: currScale*50, height: currScale*50)
            }
                
            else if diff >= 0 && diff < 37 {
                //print("here 8")
                curr_yPos = 350 - CGFloat(total_frame)*CGFloat(sin(diff*M_PI/180))
                tf.frame = CGRect(x: curr_xPos, y: curr_yPos, width: currScale*150, height: currScale*40) //approachs from bottom
                overLay.frame = CGRect(x: curr_xPos, y: curr_yPos - 40, width: currScale*50, height: currScale*50)
                
            }
                
            else {
                //print("here 9")
                curr_yPos = 700
                tf.frame = CGRect(x: curr_xPos, y: curr_yPos, width: currScale*150, height: currScale*40)
                overLay.frame = CGRect(x: curr_xPos, y: curr_yPos - 40, width: currScale*50, height: currScale*50)
            }
            
        }

    }
    
    
    func outputRotationData(_ rotation:CMDeviceMotion)
    {
        let attitude = rotation.attitude

        if abs(last_pitch - attitude.pitch*180/M_PI) > 0.25  && h_flag == true {
            last_pitch = attitude.pitch*180/M_PI
            if fetch_flag == true {
                y_angle_adjust(pitch_: last_pitch, acc_z_: acc_z_curr)
            }
            
        }
        
    }
    
    
    //creates the icon for the proper message
    func overLayer() {
        if self.type_ == 0{
            overLay.image = #imageLiteral(resourceName: "Geo-fence-50")
        }
        
        else if self.type_ == 1 {
            overLay.image = #imageLiteral(resourceName: "Happy-50")
        }
        
        else if self.type_ == 2 {
            overLay.image = #imageLiteral(resourceName: "Information-50")
        }
        
        else if self.type_ == 3 {
            overLay.image = #imageLiteral(resourceName: "Home-50")
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading
        //print(angle)
        //tf.text = String(describing: message_top)
        tf.text = message_top

      

        var diff = angle - heading
        print("angle", angle)
        print("heading", heading)
        diff = diff + 180

        diff = diff/360

        if diff > 1{
            diff = diff - 1
            diff = diff*360
            diff = diff - 180

        }

        else if diff < -1 {
            diff = diff + 1
            diff = diff*360
            diff = diff + 180
        }
        
        else {
            diff = diff*360
            diff = diff - 180
        }
        
        
        let frame = augmentedView.frame.width/2
        var total_frame = sin(36.5*M_PI/180)
        total_frame = 1.0/total_frame
        total_frame = total_frame*Double(frame)
        //print("sine frame", total_frame*sin(36.5*M_PI/180))

        //CGFloat(total_frame)*CGFloat(sin(diff))
        //print("sine", sin(diff))
        angle_adujust(diff_: diff, frame_: frame, total_frame_: CGFloat(total_frame))
        
        
    }
    
    
    
    //adjusts the x position based on heading
    func angle_adujust(diff_: Double, frame_: CGFloat, total_frame_: CGFloat) {
        let diff = diff_
        let frame = frame_
        //if abs(diff) <= 180 {
            if  diff >= 0 && diff < 37 {
                print("here 1")
                curr_xPos = frame + total_frame_*CGFloat(sin(diff*M_PI/180)) - 42
                tf.frame = CGRect(x: curr_xPos, y: curr_yPos, width: currScale*150, height: currScale*40) //approachs from right
                overLay.frame = CGRect(x: curr_xPos, y: curr_yPos - 40, width: currScale*50, height: currScale*50)
                h_flag = true
            }
            else if diff > -37 && diff < 0 {
                print("here 2")
                curr_xPos = frame + total_frame_*CGFloat(sin((diff)*M_PI/180)) - 52
                tf.frame = CGRect(x: curr_xPos, y: curr_yPos, width: currScale*150, height: currScale*40)  //approaches from left
                overLay.frame = CGRect(x: curr_xPos, y: curr_yPos - 40, width: currScale*50, height: currScale*50)
                h_flag = true
            }
            else {
                print("here 3")
                tf.frame = CGRect(x: 500, y: curr_yPos, width: currScale*150, height: currScale*40)
                overLay.frame = CGRect(x: 500, y: curr_yPos - 40, width: currScale*50, height: currScale*50)
                h_flag = false
            }
      
    }
    
    //findes the nearest result
    func nearest() {
        
        let location1 = CLLocation(latitude: lat, longitude: long)
        var location2 : CLLocation
        var distance : Double = 0.0
        var smallest : Double = 0.0
        var spot : Int?
        
        for i in 0 ..< self.texts.count {
            
            location2 = CLLocation(latitude: Double(self.texts[i].latitude), longitude: Double(self.texts[i].longitude))
            distance = location1.distance(from: location2)
            
            if i == 0 {
                spot = 0
                smallest = distance
            }
            
            if distance < smallest {
                smallest = distance
                spot = i
            }
            
        }
        
        distances.append(smallest)
        self.final_text = self.texts[spot!]
        //print(spot!)
        self.message_top = (self.final_text?.message)!
        self.temp_height = (self.final_text?.height)!
        self.type_ = (self.final_text?.type)!
    }
    
    
    func angle_() {
        
        x_diff = Double((final_text?.latitude)!) - lat
        y_diff = Double((final_text?.longitude)!) - long
        
        angle = atan(y_diff/x_diff)
        angle = angle*180/M_PI
        
        print("angle 1", angle)
        
        if x_diff >= 0 && y_diff >= 0{
            
        }
        
        else if x_diff > 0 && y_diff < 0 {
            angle = 360 + angle
        }
        
        else if x_diff < 0 && y_diff < 0 {
            angle = 180 + angle
        }
        
        else if x_diff < 0 && y_diff > 0 {
            angle = 180 + angle
        }
        
        
    }
    
    
    func fetch() {
        rootRef.observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            //print(FIRDataSnapshot.childrenCount) // I got the expected number of items
            let enumerator = FIRDataSnapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                let dictionary = rest.value as? [String: AnyObject]
                let text = Placed(latitude: dictionary!["latitude"]! as! Double, longitude: dictionary!["longitude"]! as! Double, message: dictionary!["message"]! as! String, height: dictionary!["height"]! as! Int, type: dictionary!["type"]! as! Int)
                self.texts.append(text)
                //print(self.texts[self.texts.count-1].latitude)
                //print(self.texts[self.texts.count-1].longitude)
                //print(self.texts[self.texts.count-1].message)
                self.nearest()
                self.angle_()
                self.fetch_flag = true

            }
        }, withCancel: nil)
        
    }

}
