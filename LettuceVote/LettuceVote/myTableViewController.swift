//
//  myTableViewController.swift
//  FirebaseTest
//
//  Created by Jeremy Cohen on 4/3/20.
//  Copyright © 2020 Jeremy Cohen. All rights reserved.
//

import UIKit
import FirebaseDatabase
struct Restaurant: Codable {
    var name:String
    var bump:Int
    var remove:Int
    var bumped:Bool
    var removed:Bool
    var hours:String
    var address: [String:String]?
    var restaurant_phone:String
    var price_range:String
    var active:Bool
}
struct Todo: Codable {
    var result: CurrentData
}

struct CurrentData: Codable {
    var data: [RestaurantData]
}

struct RestaurantData: Codable {
    var cuisines: [String]
    var hours: String
    var price_range: String
    var restaurant_name: String
    var restaurant_phone: String
    var address:[String:String]
}

class myTableViewCell: UITableViewCell {
    var groupID:String = ""
    @IBOutlet weak var voteLabel: UILabel!
    var restaurantID: String = ""
    var restaurantObject:Restaurant?
    var ref:DatabaseReference?
    var upButtonTapped:Bool = false
    var vc:myTableViewController?
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    var downButtonTapped:Bool = false
    @IBAction func upButton(_ sender: Any) {
        ref = Database.database().reference()
        if !upButtonTapped {
            upButtonTapped = true
            self.ref?.child("/Restaurants/\(groupID)/\(restaurantID)/bump").setValue(restaurantObject!.bump + 1)
            upButton.tintColor = .blue
            vc!.allKeys[restaurantID]!.bumped = true
        }
        else if upButtonTapped {
            upButtonTapped = false
             self.ref?.child("/Restaurants/\(groupID)/\(restaurantID)/bump").setValue(restaurantObject!.bump - 1)
            upButton.tintColor = .gray
            vc!.allKeys[restaurantID]!.bumped = false
        }
    }
    func fetchRemoveValue(completionHandler: @escaping (Int) -> Void) {
        let ref = Database.database().reference()
        ref.child("Restaurants/\(groupID)/\(restaurantID)/remove").observeSingleEvent(of: .value, with: {( snapshot) in
            if let val = snapshot.value as? Int{
                completionHandler(val)
            }
            completionHandler(-98)
          })
    }
    @IBAction func downButton(_ sender: Any) {
        let ref = Database.database().reference()
        if !downButtonTapped {
             self.fetchRemoveValue { val in
                let refer = Database.database().reference()
                if (val + 1 >= self.vc!.removeValue && self.vc!.removeActive){
                    refer.child("/Restaurants/\(self.groupID)/\(self.restaurantID)").removeValue()
                }
                else if (val != -98){
                    self.downButtonTapped = true
                    refer.child("/Restaurants/\(self.groupID)/\(self.restaurantID)/remove").setValue(self.restaurantObject!.remove + 1)
                    self.downButton.tintColor = .red
                    self.vc!.allKeys[self.restaurantID]!.removed = true
                }
            }
        }
        else if downButtonTapped {
            downButtonTapped = false
            ref.child("/Restaurants/\(groupID)/\(restaurantID)/remove").setValue(restaurantObject!.remove - 1)
            downButton.tintColor = .gray
            vc!.allKeys[restaurantID]!.removed = false
        }
    }
    @IBOutlet weak var songLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
class myTableViewController: UITableViewController {
    var joinAdmin:Bool = false
    var resetBool = false
    var searchLatitude: Double = 0.0
    var searchLongitude: Double = 0.0
    var groupID:String = ""
    var adminBool:Bool = false
    var removeActive:Bool = false
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var endVoting: UIButton!
    @IBAction func endButtonAction(_ sender: Any) {
        let ref = Database.database().reference()
        ref.child("Groups/\(self.groupID)/status").setValue("ended")
        endButton.isHidden = true
        resetButton.isHidden = false
    }
    @IBAction func resetAction(_ sender: Any) {
        let ref = Database.database().reference()
        ref.child("Groups/\(groupID)/status").setValue("active")
        ref.child("Restaurants/\(groupID)/").removeValue()
        getAllDataAdmin(gid: groupID)
        /*
        for key in sortedKeys{
            ref.child("Restaurants/\(groupID)/\(key)/bump").setValue(0)
            ref.child("Restaurants/\(groupID)/\(key)/remove").setValue(0)
        }
        for key in removedKeys{
            let restaurant = allRemovedKeys[key]!
            ref.child("Restaurants/\(groupID)/\(key)").setValue(["name": restaurant.name, "phone": restaurant.restaurant_phone, "hours": restaurant.hours, "price": restaurant.price_range, "bump": 0, "remove": 0, "address": restaurant.address])
        }
 */
        sortedKeys.removeAll()
        allKeys.removeAll()
        resetButton.isHidden = true
        endVoting.isHidden = false
    }
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    var ref:DatabaseReference?
    var databaseHandleAdd:DatabaseHandle?
    var databaseHandleUpdate:DatabaseHandle?
    var databaseHandleDelete:DatabaseHandle?
    var databaseHandleStatus:DatabaseHandle?
    
    var removeValue: Int = 2
    var allKeys: [String: Restaurant] = [:]
    var sortedKeys: [String] = []
    var removedKeys: [String] = []
    var allRemovedKeys: [String: Restaurant] = [:]
    func getSortedKeys(allKeys: [String:Restaurant]) -> [String]{
        return allKeys.keys.sorted(by: { (firstKey, secondKey) -> Bool in
            if (self.allKeys[firstKey]!.bump != self.allKeys[secondKey]!.bump) {
                return self.allKeys[firstKey]!.bump > self.allKeys[secondKey]!.bump// first is first
            }
            return self.allKeys[firstKey]!.name > self.allKeys[secondKey]!.name //if true, then first is first. else second is first
        })
    }
    func accessAPI(longitude:Double,latitude:Double,distance:Int){
        let mySession = URLSession(configuration: URLSessionConfiguration.default)
        
        let headers = [
            "x-rapidapi-host": "us-restaurant-menus.p.rapidapi.com",
            "x-rapidapi-key": "ae9b540a6dmsh50f616e9362c4cdp1bae2ajsn9032d289d579"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://us-restaurant-menus.p.rapidapi.com/restaurants/search/geo?page=1&lon=\(longitude)&lat=\(latitude)&distance=\(distance)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        var restaurantlist:[RestaurantData] = []
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
            }
            guard let jsonData = data else {
                print("No data")
                return
            }
            print("Got the data from network")
            
            let decoder = JSONDecoder()
            
            do {
                let allRestaurants = try decoder.decode(Todo.self, from: jsonData)
                restaurantlist = allRestaurants.result.data
                let ref = Database.database().reference()
                for restaurant in restaurantlist{
                    ref.child("Restaurants/\(self.groupID)").childByAutoId().setValue(["name": restaurant.restaurant_name, "phone": restaurant.restaurant_phone, "hours": restaurant.hours, "price": restaurant.price_range, "bump": 0, "remove": 0, "address": restaurant.address])
                }
                
            } catch {
                print("JSON Decode error")
                return
            }
        })
        dataTask.resume()
    }
    func getAllDataAdmin(gid: String){
        
        // TODO: get all restaurants from API and upload to Firebase
        //TODO:Integrate so this is not hardcoded location
        accessAPI(longitude: self.searchLongitude, latitude: self.searchLatitude, distance: 5)
        //TODO: double check formatting is correct in firebase? add more fields to restaurant data struct if wanted.
    }
    func getAllData(gid: String){
        let ref = Database.database().reference()
        databaseHandleUpdate = ref.child("Restaurants/\(gid)").observe(.childChanged, with: { (snapshot) in
            let dict = snapshot.value! as! [String: Any]
            self.allKeys[snapshot.key]!.bump = dict["bump"] as! Int
            self.allKeys[snapshot.key]!.remove = dict["remove"] as! Int
            self.sortedKeys = self.getSortedKeys(allKeys: self.allKeys)
            self.tableView.reloadData()
        })
        databaseHandleDelete = ref.child("Restaurants/\(gid)").observe(.childRemoved, with: { (snapshot) in
            let key = snapshot.key
            self.removedKeys.append(key)
            self.allRemovedKeys[key] = self.allKeys[key]
            self.allKeys.removeValue(forKey: key)
            self.sortedKeys = self.getSortedKeys(allKeys: self.allKeys)
            self.tableView.reloadData()
        })
        databaseHandleAdd =
            ref.child("Restaurants/\(gid)").observe(.childAdded) { (snapshot) in
            let id = snapshot.key
            let dict = snapshot.value as! [String: Any]
                let s = Restaurant(name: dict["name"] as! String, bump: dict["bump"] as! Int, remove: dict["remove"] as! Int, bumped: false, removed: false, hours: dict["hours"] as! String, address: dict["address"] as? [String:String], restaurant_phone: dict["phone"] as! String, price_range: dict["price"] as! String, active: true)
            self.allKeys[id] = s
            self.sortedKeys = self.getSortedKeys(allKeys: self.allKeys)
            
 
            self.tableView.reloadData()
        }
        databaseHandleStatus = ref.child("Groups/\(gid)/status").observe(.value, with: { (snapshot) in
            if let status = snapshot.value as? String{
                if status == "ended"{
                    for res in self.sortedKeys{
                        self.allKeys[res]?.active = false
                    }
                    self.tableView.reloadData()
                    self.performSegue(withIdentifier: "endSession", sender: nil)
                    if self.adminBool{
                        self.endButton.isHidden = true
                        self.resetButton.isHidden = false
                    }
                }
                else if status == "active"{
                    for res in self.sortedKeys{
                        self.allKeys[res]?.active = true
                        self.allKeys[res]?.bumped = false
                        self.allKeys[res]?.removed = false
                    }
                    self.tableView.reloadData()
                }
            }
        })
        ref.child("Groups/\(gid)/remove").observeSingleEvent(of: .value, with: { (snapshot) in
            if let val = snapshot.value as? Int{
                if val != -100{
                    self.removeActive = true
                    self.removeValue = val
                }
            }
        })
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                for res in self.sortedKeys{
                    self.allKeys[res]?.active = true
                }
                self.tableView.reloadData()
            } else {
                DispatchQueue.main.async {
                    for res in self.sortedKeys{
                        self.allKeys[res]?.active = false
                    }
                    self.tableView.reloadData()
                    let alert1 = UIAlertController(title: "Internet Disconnected", message: "You have been disconeccted from the internet.", preferredStyle: .alert)
                    alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert1, animated: true)
                }
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print (self.searchLatitude)
        print (self.searchLongitude)
        groupLabel.text = "GroupID: \(groupID)"
        groupLabel.textColor = UIColor.white
        groupLabel.backgroundColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        resetButton.isHidden = true
        if (adminBool){
            getAllDataAdmin(gid: self.groupID)
        }
        else if (!joinAdmin){
            endVoting.isHidden = true
            endVoting.isEnabled = false
        }
        getAllData(gid: self.groupID)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sortedKeys.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! myTableViewCell
        let id = sortedKeys[indexPath.row]
        let restaurant = allKeys[id]!
        if (!restaurant.bumped){
            cell.upButton.tintColor = .gray
            cell.upButtonTapped = false
        }
        else {
            cell.upButton.tintColor = .blue
            cell.upButtonTapped = true
        }
        if (!restaurant.removed){
            cell.downButton.tintColor = .gray
            cell.downButtonTapped = false
        }
        else {
            cell.downButton.tintColor = .red
            cell.downButtonTapped = true
        }
        if (!restaurant.active){
            cell.downButton.isHidden = true
            cell.upButton.isHidden = true
        }
        else{
            if (removeActive){
                 cell.downButton.isHidden = false
            }
            else{
                cell.downButton.isHidden = true
            }
            cell.upButton.isHidden = false
        }
        cell.backgroundColor = UIColor(red: 201.0/255.0, green: 226.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        cell.songLabel.text = allKeys[id]!.name
        cell.restaurantID = id
        cell.groupID = self.groupID
        cell.voteLabel.text = String(allKeys[id]!.bump)
        cell.restaurantObject = allKeys[id]
        cell.vc = self
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailSegue"){
            let myRow = tableView!.indexPathForSelectedRow
            let restaurantKey = sortedKeys[myRow!.row]
            let detailVC = segue.destination as! detailViewController
            detailVC.adminBool = false
            detailVC.GroupID = self.groupID
            detailVC.restaurantObject = self.allKeys[restaurantKey]
        }
        if (segue.identifier == "endSession"){
            let endVC = segue.destination as! endVotingViewController
            if sortedKeys.count > 0{
                let id = sortedKeys[0]
                endVC.winRestaurant = allKeys[id]!
            }
            
            
        }
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
