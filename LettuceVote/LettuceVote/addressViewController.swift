//
//  addressViewController.swift
//  testLocation
//
//  Created by Matt Jogodnik on 4/15/20.
//  Copyright © 2020 Matt Jogodnik. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
class addressViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var findCoords: UIButton!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var latInput: UITextField!
    @IBOutlet weak var longInput: UITextField!
    var submitted:Bool = false
    var groupID: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 201.0/255.0, green: 226.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        findCoords.applyDesign()
        submit.applyDesign()
        let tap = UITapGestureRecognizer(target: self.view,
                                         action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    
    @IBAction func findCoordButtonClicked(_ sender: Any) {
        
        let address = addressInput.text
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coords:CLLocationCoordinate2D = placemark.location!.coordinate
                self.latInput.text = String(coords.latitude)
                self.longInput.text = String(coords.longitude)
            }
        })
        
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        if let APIlat = Double(latInput.text!), let APIlong = Double(longInput.text!){
             self.performSegue(withIdentifier: "addressSegue", sender: nil)
             let ref = Database.database().reference()
             ref.child("Restaurants/\(groupID)/").removeValue()
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let lat = latInput.text, let long = longInput.text{
            let destVC = segue.destination as! myTableViewController
            if let latDouble = Double(lat), let longDouble = Double(long){
                destVC.searchLatitude = latDouble
                destVC.searchLongitude =  longDouble
            }
            destVC.groupID = self.groupID
            destVC.adminBool = true
        }
        
    }

}
