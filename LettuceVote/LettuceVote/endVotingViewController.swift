//
//  endVotingViewController.swift
//  FirebaseTest
//
//  Created by Jeremy Cohen on 4/20/20.
//  Copyright © 2020 Jeremy Cohen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit

class endVotingViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var takeMeThere: UIButton!
    
    @IBOutlet weak var restaurantLabel: UILabel?
    var winRestaurant:Restaurant?
    @IBAction func directionButton(_ sender: Any) {
        let address = winRestaurant?.address?["formatted"]
        let geocoder = CLGeocoder()

            geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    print("Error", error)
                }
                if let placemark = placemarks?.first {
                    let coords:CLLocationCoordinate2D = placemark.location!.coordinate
                    
                    let regionDistance:CLLocationDistance = 1000
                    let regionSpan = MKCoordinateRegion.init(center: coords, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                    
                    let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
                    
                    let placemark = MKPlacemark(coordinate: coords)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = self.winRestaurant!.name
                    mapItem.openInMaps(launchOptions: options)
                }
        })
        
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if (winRestaurant != nil){
            let res = winRestaurant!
            let n = res.name
            let b = res.bump
            restaurantLabel?.text = "\(n) won with \(b) votes!"
        }
        else{
            restaurantLabel?.text = "You did not select any restauruant."
        }
        self.view.backgroundColor = UIColor(red: 201.0/255.0, green: 226.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        restaurantLabel?.textColor = UIColor.white
        takeMeThere.applyDesign()
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
