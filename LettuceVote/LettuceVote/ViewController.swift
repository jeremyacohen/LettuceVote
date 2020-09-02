//
//  ViewController.swift
//  FirebaseTest
//
//  Created by Jeremy Cohen on 4/3/20.
//  Copyright © 2020 Jeremy Cohen. All rights reserved.
//

import UIKit
import FirebaseDatabase
extension UIView {
    func fadeIn(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 1 },
                       completion: { (value: Bool) in
                          if let complete = onCompletion { complete() }
                       }
        )
    }

    func fadeOut(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 0 },
                       completion: { (value: Bool) in
                           self.isHidden = true
                           if let complete = onCompletion { complete() }
                       }
        )
    }

}
class ViewController: UIViewController {
    var id:String = "0"
    var ref:DatabaseReference?


    @IBOutlet weak var removeActive: UISwitch!
    @IBOutlet weak var removeField: UITextField!
    @IBOutlet weak var existLabel: UILabel!
    @IBOutlet weak var groupTextValue: UITextField!
    @IBOutlet weak var newView: UIView!
    @IBAction func createButton(_ sender: Any) {
        self.fetchInternetConnection{ fetchedConnection in
                if fetchedConnection{
                    self.fetchGroupName { fetchedGroupName in
                        var removeCount = -100
                        if self.removeActive.isOn{
                            if let t = self.removeField.text, let r = Int(t), r > 0{
                                removeCount = r
                            }
                            else{
                                self.validLabel.isHidden = false
                                self.validLabel.text = "You must sumbit a number above 0"
                                self.validLabel.textColor = .red
                                return
                            }
                        }
                        if !fetchedGroupName.contains(self.groupTextValue.text!) && self.groupTextValue.text! != ""{
                              let ref = Database.database().reference()
                            ref.child("Groups/\(self.groupTextValue.text!)").setValue(["status": "active", "remove": removeCount])
                              self.performSegue(withIdentifier: "createSegue", sender: nil)
                              self.newView.isHidden = true
                          }
                          else{
                              self.validLabel.isHidden = false
                              self.validLabel.text = "Name Taken"
                              self.validLabel.textColor = .red
                          }
                      }
                }
                if !fetchedConnection{
                    self.validLabel.isHidden = false
                    self.validLabel.text = "You are disconnected from the internet."
                    self.validLabel.textColor = .red
                    return
                }
            }
  
        
        // TODO: get latitude/longitude/ZIP/etc
        
    }
    @IBAction func newGroupButton(_ sender: Any) {
        newView.fadeIn()
        validLabel.isHidden = true
    }
    @IBAction func cancelButton(_ sender: Any) {
        newView.fadeOut()
        validLabel.isHidden = true
    }
    @IBAction func joinButton(_ sender: Any) {
        self.fetchInternetConnection{ fetchedConnection in
            if fetchedConnection{
                self.fetchGroupName { fetchedGroupName in
                    if fetchedGroupName.contains(self.textField.text!){
                        self.performSegue(withIdentifier: "joinSegue", sender: nil)
                        self.existLabel.isHidden = true
                    }
                    else{
                        self.existLabel.isHidden = false
                        self.existLabel.text = "That group does not exist."
                    }
                }
            }
            else{
                self.existLabel.isHidden = false
                self.existLabel.text = "Disconnected"
            }
        }
        
    }
    
    //var completionHandler:DatabaseHandle?
    
    func fetchGroupName(completionHandler: @escaping (Set<String>) -> Void) {
        self.ref = Database.database().reference()
        self.ref?.child("Groups").observeSingleEvent(of: .value, with: {( snapshot) in
            var groupSet = Set<String>()
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                groupSet.insert(snap.key)
            }
            completionHandler(groupSet)
          })
    }
    func fetchInternetConnection(completionHandler: @escaping (Bool) -> Void) {
        self.ref = Database.database().reference()
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observeSingleEvent(of: .value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        })
    }
    @IBAction func validateButton(_ sender: Any) {
        self.fetchGroupName { fetchedGroupName in
            if fetchedGroupName.contains(self.groupTextValue.text!) || self.groupTextValue.text! == ""{
                self.validLabel.isHidden = false
                self.validLabel.text = "Name Taken"
                self.validLabel.textColor = .red
            }
            else{
                self.validLabel.isHidden = false
                self.validLabel.text = "Valid!"
                self.validLabel.textColor = .green
            }
        }
    }
    @IBOutlet weak var joinGroup: UIButton!
    @IBOutlet weak var validLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var newGroup: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var validate: UIButton!
    @IBOutlet weak var createGroup: UIButton!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var adminSlider: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 201.0/255.0, green: 226.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        newView.backgroundColor = UIColor(red: 201.0/255.0, green: 226.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        groupName.textColor = UIColor.white
        newGroup.applyDesign()
        joinGroup.applyDesign()
        cancel.applyDesign()
        createGroup.applyDesign()
        validate.applyDesign()
        existLabel.isHidden = true
        existLabel.textColor = UIColor.white
        existLabel.text = "This group does not exist"
        existLabel.textColor = .red
        newView.isHidden = true
        removeField.keyboardType = .numberPad
        
        self.fetchInternetConnection{ fetchedConnection in
            if fetchedConnection{
                print ("Connected")
            }
            else{
                print ("Disconnected")
            }
        }
        
        let tap = UITapGestureRecognizer(target: self.view,
                                         action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "joinSegue" {
            let destVC = segue.destination as! myTableViewController
            destVC.groupID = textField.text!
            destVC.adminBool = false
            if adminSlider.selectedSegmentIndex == 0{
                destVC.joinAdmin = false
            }
            else{
                destVC.joinAdmin = true
            }
            
            
        }
        if segue.identifier == "createSegue" {
            let tabCtrl: UITabBarController = segue.destination as! MyTabViewController
            let destVC = tabCtrl.viewControllers![1] as! addressViewController
            let locDestVC = tabCtrl.viewControllers![0] as! locationViewController
            destVC.groupID = groupTextValue.text!
            locDestVC.groupID = groupTextValue.text!
        }
        
    }


}

extension UIButton {
    func applyDesign() {
        self.backgroundColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        self.layer.cornerRadius = 15
        self.setTitleColor(UIColor.white, for: .normal)
        self.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}

extension UILabel {
    func applyDesign() {
        self.textColor = UIColor.white
    }
}
