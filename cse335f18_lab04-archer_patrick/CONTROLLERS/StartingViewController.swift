//
//  ViewController.swift
//  cse335f18_lab04-archer_patrick
//
//  Created by Patrick Archer on 9/27/18.
//  Copyright © 2018 Patrick Archer - Self. All rights reserved.
//

import UIKit
import Foundation

class StartingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var firstLoadSoCreateDict:Bool = true

    // object instance of location object that has an array of locations
    // and the section headers for the location table
    var myLocList:locations =  locations()
    
    // dictionary with section headers as a key and location object as a value
    var locList = [String: [location]]()
    
    // outlet for location table in main view
    @IBOutlet weak var locTable: UITableView!
    
    // action outlet for addLocation button
    @IBAction func button_addLocation(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Location", message: "*Location name is REQUIRED to start with a capital letter.*", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Location Name Here"
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Location Description Here"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            let desc = alert.textFields![1].text!
            if let name = alert.textFields?.first?.text {
                
                //print("Location Name: \(name)") // debug
                //print("Location Desc: \(desc)")   // debug
                
                //print(self.myLocList.locations.description) // debug
                
                let newLocation = location(lName: name, lDesc: desc, lImage: "newyork.jpg")
                self.myLocList.locations.append(newLocation)
                
                //print(self.myLocList.locations.description) // debug
                
                let LName = name
                let endIndex = LName.index((LName.startIndex), offsetBy: 1)
                let locationKey = String(LName[(..<endIndex)])
                
                // adding the new loc object to the dictionary
                if var locObjects = self.locList[locationKey] {
                    locObjects.append(newLocation)
                    self.locList[locationKey] = locObjects
                    self.locTable.reloadData()  // update table contents
                }else{
                    self.locList[locationKey] = [newLocation]
                    self.locTable.reloadData()  // update table contents
                }
                self.locTable.reloadData()  // update table contents
                
                print("Location Added: \(LName), with Description: \(desc)")    // debug
                print("Total number of locations stored: \(self.myLocList.locations.count)")    // debug
            }
            
        }))
        
        self.present(alert, animated: true)
        
        // update table contents
        self.locTable.reloadData()
    }
    
    /*==========================================================*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // build LocDictionary *<TODO>: only on first load*
        createLocDictionary()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*==========================================================*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let selectedIndex: IndexPath = self.locTable.indexPath(for: sender as! UITableViewCell)!
        
        // access the section for the selected row
        let locKey = myLocList.tableSectionTitles[selectedIndex.section]
        
        // get the location object for the selected row in the section
        let loc = locList[locKey]![selectedIndex.row]
        
        if(segue.identifier == "detailedViewSegue"){
            // if segue to DetailedView
            if let detailViewController: DetailedViewController = segue.destination as? DetailedViewController {
                
                print("Made it to detailedViewSegue location selection method")    // debug
                
                // pass user-selected location object to DetailedViewController
                detailViewController.userSelectedEntry = loc
                
                print("Segue-passed location name: \(loc.locName)") // debug

            }
        }
    }
    
    // used by Exit handler to unwind segue and pass data to the original page
    @IBAction func unwindSegueToStartingViewController(segue: UIStoryboardSegue)
    {
        print("Unwinding page segue")
        
        // if unwinding from DetailedViewController, do...
        if let sourceViewController = segue.source as? DetailedViewController
        {
            let dataReceived:location? = sourceViewController.userSelectedEntry
            
            // update location database with loc values passed back by DetailedViewController
            self.locList[(dataReceived?.locName)!] = [dataReceived!]
            
            // update table contents
            self.locTable.reloadData()

        }
        /*// if unwinding from MapViewController, do...
        else if let sourceViewController = segue.source as? MapViewController
        {
            let dataReceived:location? = sourceViewController.userSelectedEntry
            
            // update location database with loc values passed back by MapViewController
            //self.locList[(dataReceived?.locName)!] = [dataReceived!]
            
            // update table contents
            self.locTable.reloadData()
        }*/
    }
    
    /*==========================================================*/
    
    // delegate to set number of sections in table
    func numberOfSections(in tableView: UITableView) -> Int {
        // get the section count
        return myLocList.tableSectionTitles.count
    }
    
    // delegate to count number of rows in a section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        // get the section title
        let locKey = myLocList.tableSectionTitles[section]
        
        // use the section title to count how many locations are in that section
        if let locValues = locList[locKey]
        {
            return locValues.count
        }
        else {
            return 0
        }
    }
    
    // delegate to return the heading string for each section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // returns the heading for each section
        return myLocList.tableSectionTitles[section]
    }
    
    // delegate to build the actual table, including the section headers/keys and each row individually
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "fruitCell", for: indexPath) as! FruitTableViewCell
        //let cell = tableView.dequeueReusableCell(withIdentifier: "locCell", for: indexPath) as! LocTableViewCell
        let Lcell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LocTableViewCell
        
        // get the section key
        let locKey = myLocList.tableSectionTitles[indexPath.section]
        
        // build each each row for section
        if let locValues = locList[locKey]{
            Lcell.locTitle.text = locValues[indexPath.row].locName;
            Lcell.locDescription.text = locValues[indexPath.row].locDescription;
            Lcell.locImage.image = UIImage(named: locValues[indexPath.row].locImageName)
        }
        
        return Lcell
        
    }
    
    // delegate to allow row entry editing
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // delegate to deal with swipe-to-delete entry functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from dictionary and updating the tableview
            print("Inside tableView delete handler delegate.")  // debug
            
            let locKeyToRemove = myLocList.tableSectionTitles[indexPath.section]
            self.locList[locKeyToRemove] = []
            
            // update table contents
            self.locTable.reloadData()
        }
    }
    
    /*==========================================================*/
    
    func createLocDictionary() {
        
        print("Executing createLocDictionary()") // debug
        print("firstLoadSoCreateDict = \(firstLoadSoCreateDict)")   // debug
        
        if (firstLoadSoCreateDict == true)
        {
            // for each location in the location list from the loc object
            for loc in myLocList.locations {
                // extract the first letter as a string for the key
                let lName = loc.locName
                
                let endIndex = lName.index((lName.startIndex), offsetBy: 1)
                
                let locKey = String(lName[(..<endIndex)])
                
                // build the location object array for each key
                if var locObjects = locList[locKey] {
                    locObjects.append(loc)
                    locList[locKey] = locObjects
                } else {
                    locList[locKey] = [loc]
                }
                
            }
            firstLoadSoCreateDict = false
        }
        
        self.locTable.reloadData()
    }
    
    /*==========================================================*/

    
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
    
}

