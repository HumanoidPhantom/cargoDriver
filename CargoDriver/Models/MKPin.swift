//
//  MKPin.swift
//  CargoDriver
//
//  Created by Phantom on 26/04/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import Foundation
import MapKit

class MKPin: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
}