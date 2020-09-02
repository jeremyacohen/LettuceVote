//
//  detailViewController.swift
//  FirebaseTest
//
//  Created by Jeremy Cohen on 4/9/20.
//  Copyright © 2020 Jeremy Cohen. All rights reserved.
//

import UIKit
import FirebaseDatabase

class detailViewController: UIViewController {
    var GroupID: String = ""
    var restaurantID: String = ""
    var restaurantObject: Restaurant?
    var adminBool:Bool = false
    var upcomingBool:Bool = false
    var upTapped:Bool = false
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var bumpLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var restaurantInfoView: UIView!
    @IBOutlet weak var phoneNumber: UILabel!
    
    @IBOutlet weak var priceRange: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBAction func removeButtonAction(_ sender: Any) {
        let ref = Database.database().reference()
        ref.child("/Restaurants/\(GroupID)/\(restaurantID)").removeValue()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if !(adminBool && upcomingBool) {
            removeButton.isHidden = true
            removeButton.isEnabled = false
        }
        phoneNumber.textColor = UIColor(red: 201.0/255.0, green: 226.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        location.textColor = UIColor(red: 201.0/255.0, green: 226.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        hours.textColor = UIColor(red: 201.0/255.0, green: 226.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        priceRange.textColor = UIColor(red: 201.0/255.0, green: 226.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        self.view.backgroundColor = UIColor(red: 201.0/255.0, green: 226.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        restaurantInfoView.backgroundColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        restaurantInfoView.layer.cornerRadius = 15
        songLabel.text = restaurantObject?.name
        
        hoursLabel.text = restaurantObject?.hours
        hoursLabel.textColor = UIColor.white
        if hoursLabel.text == nil || hoursLabel.text == "" || hoursLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            hoursLabel.text = "Unavailable"
        }
        priceLabel.text = restaurantObject?.price_range
        priceLabel.textColor = UIColor.white
        if priceLabel.text == nil || hoursLabel.text == "" || priceLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            priceLabel.text = "Unavailable"
        }
        addressLabel.text = restaurantObject?.address?["formatted"]
        addressLabel.textColor = UIColor.white
        if addressLabel.text == nil || hoursLabel.text == "" || addressLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            addressLabel.text = "Unavailable"
        }
        phoneLabel.text = restaurantObject?.restaurant_phone
        phoneLabel.textColor = UIColor.white
        if phoneLabel.text == nil || hoursLabel.text == "" || phoneLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            phoneLabel.text = "Unavailable"
        }
        //bumpLabel.text = String(RestaurantObject!.bump)
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
