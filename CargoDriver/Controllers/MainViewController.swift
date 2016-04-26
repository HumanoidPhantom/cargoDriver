//
//  MainViewController.swift
//  WhereMyChild
//
//  Created by Phantom on 27/03/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    static let storyboardID = "MainViewController"
    let showAcceptedOrdersSegue = "ShowAcceptedOrdersSegue"
    let myRootRef = Firebase(url:"https://mycargodriver.firebaseio.com/orders")
    let myUserRef = Firebase(url:"https://mycargodriver.firebaseio.com/users")
    
    private var locationManager = CLLocationManager()
    private var geoDispatcher = AGGeoDispatcher()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var user: Driver?
    var pins: [Pin] = []
    var selectedPin: Pin?
    var wantToLookForUserEmail: String?
    var movingUsersPin: Pin?
    
    @IBOutlet weak var meButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var underButtonsView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: YMKMapView! {
        didSet{
            mapView.showTraffic = false
            mapView.nightMode = false
            mapView.showsUserLocation = true
            mapView.delegate = self
        }
    }
    
    // MARK: - Actions
    @IBAction func minusButton(sender: AnyObject) {
        mapView.zoomOut()
    }
    
    @IBAction func plusButton(sender: AnyObject) {
        mapView.zoomIn()
    }
    
    @IBAction func segmentedControlChange(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            hideMapView(false)
        } else {
            hideMapView(true)
        }
    }
    
    @IBAction func findMe(sender: AnyObject) {
        mapView.setCenterCoordinate(mapView.userLocation.coordinate(), animated: true)
    }
    
    //MARK: - View Controller Life Cycle
    override func viewWillAppear(animated: Bool) {
        configureLocationManager()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
                locationManager.stopUpdatingLocation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if wantToLookForUserEmail == nil {
            findUserByOrderId(2)
        } else {
            lookForUser()
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if let userDef = defaults.dictionaryForKey("user") as? [String: String], email = userDef["email"], name = userDef["name"] {
            self.user = Driver(email: email, name: name)
        }
        geoDispatcher.setGeocoderProvider(AGGeocodeYandexProvider())
        configureTable()
        
        loadFromFireBase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            print("Error. No such segue")
            return
        }
        
        if identifier == showAcceptedOrdersSegue {
            guard let destinationView = segue.destinationViewController as? AcceptedOrdersTableViewController else {
                print("Error. Wrong destionation view")
                return
            }
            
            destinationView.user = user
        }
    }
    
    // MARK: Segmented Control's functions
    func hideMapView (hide: Bool) {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            if hide {
                self.mapView.alpha = 0
                self.underButtonsView.alpha = 0
                self.meButton.alpha = 0
                self.tableView.alpha = 1
            } else {
                self.mapView.alpha = 1
                self.underButtonsView.alpha = 1
                self.meButton.alpha = 1
                self.tableView.alpha = 0
            }
            
        }, completion: nil)
        
    }
    
    // MARK: Table configuration
    func configureTable(){
        tableView.alpha = 0
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: Location
    func configureLocationManager () {
        if !CLLocationManager.locationServicesEnabled() {
            print("service not enabled. Error!")
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }
    
    func loadFromFireBase() {
        myRootRef.queryOrderedByChild("orderStatus").queryEqualToValue("0").observeEventType(.ChildAdded, withBlock: { snapshot in

            guard let id = Int(snapshot.key!) else {
                print("Error. Wrong order id")
                return
            }
            
            if let order = snapshot.value as? [String: String] {
                if order["acceptedUserEmail"] == nil || order["acceptedUserEmail"] == "" {
                    let destination = order["destination"] ?? ""
                    let name = order["name"] ?? ""
                    let detail = order["detail"] ?? ""
                        
                    self.addPin(destination, title: name, subtitle: detail, orderId: id)
                }
            }
            
        })
        
        myRootRef.queryOrderedByChild("orderStatus").queryEqualToValue("0").observeEventType(.ChildRemoved, withBlock: { snapshot in
                guard let id = Int(snapshot.key!) else {
                    print("Error. Wrong order id")
                    return
                }
            
                self.removePin(id)
            
            })
        
        
        myRootRef.queryOrderedByChild("orderStatus").queryEqualToValue("0").observeEventType(.ChildChanged, withBlock: { snapshot in
            guard let id = Int(snapshot.key!) else {
                print("Error. Wrong order id")
                return
            }
            
            if let order = snapshot.value as? [String: String] {
                
                let destination = order["destination"] ?? ""
                let name = order["name"] ?? ""
                let detail = order["detail"] ?? ""
                
                self.removePin(id)
            
                self.addPin(destination, title: name, subtitle: detail, orderId: id)
            }
        })
    }
    
    func findUserByOrderId(id: Int) {
        
        myRootRef.queryOrderedByKey().queryEqualToValue("\(id)")
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                if let order = snapshot.value as? [String: String] {
                    if let email = order["acceptedUserEmail"] {
                        self.wantToLookForUserEmail = email
                        
                        self.lookForUser()
                    }
                }
            })
    }
    
    func lookForUser() {

        self.myUserRef.queryOrderedByChild("email").queryEqualToValue(self.wantToLookForUserEmail!).observeEventType(.ChildChanged, withBlock: { (result) in
            print(result.value)
            if let user = result.value as? [String: String] {
                print(user)
                    let latitude = user["lat"] ?? ""
                    let longitude = user["long"] ?? ""
                    print(latitude, longitude)
                    if let lat = Double(latitude), long = Double(longitude) {
                        let coords = CLLocationCoordinate2DMake(lat, long)
                        if self.movingUsersPin != nil {
                            self.mapView.removeAnnotation(self.movingUsersPin!)
                        }
                        
                        let pin = Pin(title: "Мой заказ", subtitle: "Исполнитель моего заказа", coordinate: coords, address: "address", orderId: 2)
                        
                        self.mapView.addAnnotation(pin)
                        self.movingUsersPin = pin
                        
                    } else {
                        print("Error. Wrong lag and long values")
                    }
                
            }
        })
    }

}

extension MainViewController: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }
        mapView.setCenterCoordinate(locations.last!.coordinate, atZoomLevel: 17, animated: true)
    }
}

extension MainViewController: YMKMapViewDelegate {
    private func addPin(address: String, title: String, subtitle: String, orderId: Int) {
        CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks, error)->Void in
            let placemark = placemarks![0] as CLPlacemark
            let coords = placemark.location?.coordinate
            
            let ymkCoords = YMKMapCoordinate(latitude: coords!.latitude, longitude: coords!.longitude)
            let pin = Pin(title: title, subtitle: subtitle, coordinate: ymkCoords, address: address, orderId: orderId)
            
            self.pins.append(pin)
            
            self.mapView.addAnnotation(pin)
            
            self.tableView.reloadData()
        })
    }
    
    private func removePin(id: Int) {
        if let pinIndex = self.pins.indexOf({$0.order.id == id}) {
            self.mapView.removeAnnotation(pins[pinIndex])
            self.pins.removeAtIndex(pinIndex)
            
            tableView.reloadData()
        }
    }
    
    func mapView(mapView: YMKMapView!, annotationViewCalloutTapped view: YMKAnnotationView!) {
        guard let pin = view.annotation as? Pin else {
            print("Error. Is not Pin")
            return
        }
        
        guard let vc = self.storyboard?.instantiateViewControllerWithIdentifier(OrderConfirmationViewController.srotyboardId) as? OrderConfirmationViewController else {
            print("Error. No VC with OrderConfirmationViewController identifier")
            return
        }
        
        vc.order = pin.order
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MainViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pins.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(OrderTableViewCell.identifier, forIndexPath: indexPath) as? OrderTableViewCell else {
            return OrderTableViewCell()
        }
        
        let currentPin = pins[indexPath.row]
        cell.nameLabel.text = currentPin.order.fare.name
        cell.detailLabel.text = currentPin.order.fare.detail
        cell.addressLabel.text = currentPin.order.destinationAdress
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let pin = pins[indexPath.row]
        selectedPin = pin
        hideMapView(false)
        segmentedControl.selectedSegmentIndex = 0
        mapView.setCenterCoordinate(pin.coordinate(), atZoomLevel: 17, animated: true)
    }
}
