//
//  CreateViewController.swift
//  local2
//
//  Created by Aaron Mann on 1/11/17.
//  Copyright © 2017 Aaron Mann. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CreateViewController: UIViewController {

    let rootRef = FIRDatabase.database().reference()
    
  
    
    var long : Double = 0.0
    var lat : Double = 0.0
    var heading : Double = 0.0
    var message_ : String = ""
    var type : Int = 0
    
    var height : Int = 0
    
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var general: UIButton!
    @IBOutlet weak var social: UIButton!
    @IBOutlet weak var information: UIButton!
    @IBOutlet weak var structure: UIButton!
    
    @IBAction func save(_ sender: Any) {
        message_ = self.message.text!
        
        let post : [String : AnyObject] = ["latitude" : lat as AnyObject, "longitude" : long as AnyObject, "message" : message_ as AnyObject, "height" : height as AnyObject, "type" : type as AnyObject]
        
        rootRef.child("Texts").childByAutoId().setValue(post)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        general.backgroundColor = UIColor.clear
        social.backgroundColor = UIColor.clear
        information.backgroundColor = UIColor.clear
        structure.backgroundColor = UIColor.clear
        
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func up(_ sender: Any) {
        
        if height < 2 {
            height += 1
        }
    }

    @IBAction func down(_ sender: Any) {
        if height > -3 {
            height += -1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func general(_ sender: Any) {
        
        type = 0
        
        general.backgroundColor = UIColor.blue
        social.backgroundColor = UIColor.clear
        
        information.backgroundColor = UIColor.clear
        structure.backgroundColor = UIColor.clear
        
    }

    @IBAction func social(_ sender: Any) {
        
        type = 1
        
        general.backgroundColor = UIColor.clear
        social.backgroundColor = UIColor.blue
        
        information.backgroundColor = UIColor.clear
        structure.backgroundColor = UIColor.clear
    }
    
    @IBAction func information(_ sender: Any) {
        
        type = 2
        
        general.backgroundColor = UIColor.clear
        social.backgroundColor = UIColor.clear
        
        information.backgroundColor = UIColor.blue
        structure.backgroundColor = UIColor.clear
    }
    
    @IBAction func structure(_ sender: Any) {
        
        type = 3
        
        general.backgroundColor = UIColor.gray
        social.backgroundColor = UIColor.gray
        
        information.backgroundColor = UIColor.gray
        structure.backgroundColor = UIColor.blue
    }

}
