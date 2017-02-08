//
//  FullListTableViewController.swift
//  local2
//
//  Created by Aaron Mann on 1/13/17.
//  Copyright © 2017 Aaron Mann. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FullListTableViewController: UITableViewController {

    let rootRef = FIRDatabase.database().reference().child("Texts").ref
    
    var texts = [Placed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        fetch()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(texts.count)
        return texts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        print(texts.count)
        
        var text : Placed?
        print(indexPath.row)
        text = texts[indexPath.row]
        cell.textLabel?.text = text?.message
        
        return cell
    }
    
    
    
    func fetch() {
        rootRef.observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            //print(FIRDataSnapshot.childrenCount) // I got the expected number of items
            let enumerator = FIRDataSnapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                let dictionary = rest.value as? [String: AnyObject]
                let text = Placed(latitude: dictionary!["latitude"]! as! Double, longitude: dictionary!["longitude"]! as! Double, message: dictionary!["message"]! as! String, height: dictionary!["height"]! as! Int, type: dictionary!["type"]! as! Int)
                self.texts.append(text)
                print("list")
                print(self.texts[self.texts.count-1].latitude)
                print(self.texts[self.texts.count-1].longitude)
                print(self.texts[self.texts.count-1].message)
                
            }
        }, withCancel: nil)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
