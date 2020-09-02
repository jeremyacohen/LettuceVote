//
//  locationViewController.swift
//  FirebaseTest
//
//  Created by Matt Jogodnik on 4/15/20.
//  Copyright © 2020 Jeremy Cohen. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
class locationViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var findCoords: UIButton!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var latInput: UITextField!
    @IBOutlet weak var longInput: UITextField!
    var APIlat:Double = 0.0
    var APIlong:Double = 0.0
    var locationManager = CLLocationManager()
    var groupID:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 201.0/255.0, green: 226.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        findCoords.applyDesign()
        submit.applyDesign()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func findCoordsButtonClicked(_ sender: Any) {
        self.locationManager.requestWhenInUseAuthorization()
        
        latInput.keyboardType = UIKeyboardType.numberPad
        longInput.keyboardType = UIKeyboardType.numberPad
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userCoords:CLLocationCoordinate2D = manager.location!.coordinate
        let userLat = userCoords.latitude
        let userLong = userCoords.longitude
        locationManager.stopUpdatingLocation()
        latInput.text = String(userLat)
        longInput.text = String(userLong)
    }
    
    //Charles, APIlat and APIlong are the outputs you'll work with
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        if let APIlat = Double(latInput.text!), let APIlong = Double(longInput.text!){
            self.performSegue(withIdentifier: "groupSegue", sender: nil)
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
