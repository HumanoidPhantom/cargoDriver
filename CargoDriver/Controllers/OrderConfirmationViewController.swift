//
//  OrderConfirmationViewController.swift
//  CargoDriver
//
//  Created by Phantom on 23/04/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import UIKit
import MapKit

class OrderConfirmationViewController: UIViewController {
    
    let acceptOrderSegue = "AcceptOrderSegue"
    static let srotyboardId = "OrderConfirmationViewController"
    let myRootRef = Firebase(url:"https://mycargodriver.firebaseio.com/orders")

    var order: Order?
    var user: Driver?
    private var locationManager = CLLocationManager()
    var pin: Pin?
    @IBOutlet weak var mapView: YMKMapView! {
        didSet{
            mapView.showTraffic = false
            mapView.nightMode = false
            mapView.showsUserLocation = true
            mapView.delegate = self
            
            setCenter()
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    // MARK - Actions
    @IBAction func acceptOrder(sender: AnyObject) {
        guard let currentDriver = user else {
            print("Error. No user saved")
            return
        }
        let id = order?.id
        
        let orderRef = myRootRef.childByAppendingPath("\(id!)")
        
        let userID = ["acceptedUserEmail": currentDriver.email]
        orderRef.updateChildValues(userID, withCompletionBlock: {(error:NSError?, ref:Firebase!) in
            if (error != nil) {
                print("Data could not be saved.")
            } else {
                print("Data saved successfully!")
                guard let vc = self.storyboard?.instantiateViewControllerWithIdentifier(FinishOrderViewController.storyboardId) as? FinishOrderViewController else {
                    print("Error. No VC with OrderConfirmationViewController identifier")
                    return
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    @IBAction func zoomOutButton(sender: AnyObject) {
        mapView.zoomOut()
    }
    
    @IBAction func zoomInButton(sender: AnyObject) {
        mapView.zoomIn()
    }
    
    @IBAction func showMeButton(sender: AnyObject) {
        mapView.setCenterCoordinate(mapView.userLocation.coordinate(), animated: true)
    }
    
    @IBAction func whereToButton(sender: AnyObject) {
        if let wherePin = pin {
            mapView.setCenterCoordinate(wherePin.coordinate(), animated: true)
        }
        
    }
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userOrder = order else {
            print("Error. Order is empty")
            return
        }
        
        descriptionLabel.text = userOrder.fare.detail
        nameLabel.text = userOrder.fare.name
        addressLabel.text = userOrder.destinationAdress
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        configureLocationManager()
    }
    
    // MARK: Location
    func configureLocationManager () {
        if !CLLocationManager.locationServicesEnabled() {
            print("service not enabled. Error!")
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }
}

extension OrderConfirmationViewController: YMKMapViewDelegate {
    func setCenter() {
        if let order = self.order {
            CLGeocoder().geocodeAddressString(order.destinationAdress, completionHandler: {(placemarks, error)->Void in
                let placemark = placemarks![0] as CLPlacemark
                let coords = placemark.location?.coordinate
                let ymkCoords = YMKMapCoordinate(latitude: coords!.latitude, longitude: coords!.longitude)
                let pin = Pin(title: order.fare.name, subtitle: order.fare.detail, coordinate: ymkCoords, address: order.destinationAdress, orderId: order.id, showOrder: false)
                
                self.mapView.addAnnotation(pin)
                self.pin = pin
                self.mapView.setCenterCoordinate(coords!, atZoomLevel: 15, animated: false)
            })
        }
    }
    
}
