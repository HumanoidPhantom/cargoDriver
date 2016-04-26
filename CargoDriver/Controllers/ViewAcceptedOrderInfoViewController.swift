//
//  ViewAcceptedOrderInfoViewController.swift
//  CargoDriver
//
//  Created by Phantom on 24/04/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import UIKit

class ViewAcceptedOrderInfoViewController: UIViewController {

    static let storyboardId = "ViewAcceptedOrderInfoViewController"
    var order:Order?
    var user: Driver?
    let myRootRef = Firebase(url:"https://mycargodriver.firebaseio.com/orders")
    private var locationManager = CLLocationManager()
    var pin: Pin?
    
    @IBOutlet weak var orderStatusSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var mapView: YMKMapView! {
        didSet {
            mapView.showTraffic = false
            mapView.nightMode = false
            mapView.showsUserLocation = true
            mapView.delegate = self
            
            setCenter()
        }
    }
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func changeOrderStatus(sender: UISegmentedControl) {
        let orderStatus = sender.selectedSegmentIndex
        
        let id = order?.id
        
        let orderRef = myRootRef.childByAppendingPath("\(id!)")
        
        orderRef.updateChildValues(["orderStatus": "\(orderStatus)"], withCompletionBlock: {(error:NSError?, ref:Firebase!) in
            if (error != nil) {
                print("Data could not be saved.")
            }
        })
    }
    
    @IBAction func rejectButton(sender: AnyObject) {
        let id = order?.id
        
        let orderRef = myRootRef.childByAppendingPath("\(id!)")
        
        let fields = [
            "acceptedUserEmail": "",
            "orderStatus": "0"
        ]
        
        orderRef.updateChildValues(fields, withCompletionBlock: {(error:NSError?, ref:Firebase!) in
            if (error != nil) {
                print("Data could not be saved.")
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
    
    @IBAction func zoomOutButton(sender: AnyObject) {
        mapView.zoomOut()
    }
    
    @IBAction func zoomInButton(sender: AnyObject) {
        mapView.zoomIn()
    }
    
    @IBAction func meButton(sender: AnyObject) {
        mapView.setCenterCoordinate(mapView.userLocation.coordinate(), animated: true)
    }
    
    @IBAction func whereToButton(sender: AnyObject) {
        if let wherePin = pin {
            mapView.setCenterCoordinate(wherePin.coordinate(), animated: true)
        }
    }
    
    // MARK: - VC Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let seeOrder = order {
            addressLabel.text = seeOrder.destinationAdress
            nameLabel.text = seeOrder.fare.name
            detailLabel.text = seeOrder.fare.detail
            guard let status = Int(seeOrder.orderStatus) else {
                print("Error. Status is not an Int number")
                return
            }
            
            orderStatusSegmentedControl.selectedSegmentIndex = status
        }
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


extension ViewAcceptedOrderInfoViewController: YMKMapViewDelegate {
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
