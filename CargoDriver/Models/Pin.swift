//
//  Pin.swift
//  CargoDriver
//
//  Created by Phantom on 03/04/16.
//  Copyright © 2016 Phantom. All rights reserved.
//


import Foundation
import MapKit

class Pin: NSObject, YMKAnnotation {
    let atitle: String
    var asubtitle: String
    var coordinateCashMachine: YMKMapCoordinate
    let order: Order
    
    func coordinate() -> YMKMapCoordinate{
        return coordinateCashMachine
    }
    
    func title() -> String! {
        return atitle
    }

    func subtitle() -> String! {
        return asubtitle
    }
    
    init(title: String, subtitle: String, coordinate: YMKMapCoordinate, address: String, orderId: Int, showOrder: Bool = true){
        self.atitle = title
        self.asubtitle = subtitle
        if showOrder {
            self.asubtitle += "\nЗаказать"
        }
        
        self.order = Order(id: orderId, destination: address, name: title, detail: subtitle)
        
        self.coordinateCashMachine = coordinate
        super.init()
    }
    
}