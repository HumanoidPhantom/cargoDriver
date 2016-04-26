//
//  Order.swift
//  CargoDriver
//
//  Created by Phantom on 03/04/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import Foundation

class Order {
    var id = 0
    var destinationAdress = ""
    var fare: Fare!
    var orderStatus: String
    
    init(id: Int, destination: String, name: String, detail: String, orderStatus: String = "0") {
        
        self.destinationAdress = destination
        self.id = id
        self.fare = Fare(name: name, detail: detail)
        self.orderStatus = orderStatus
    }
}