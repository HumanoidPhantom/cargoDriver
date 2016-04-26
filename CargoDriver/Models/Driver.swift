//
//  Driver.swift
//  CargoDriver
//
//  Created by Phantom on 03/04/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import Foundation

class Driver {
    var name = ""
    var fare: Fare?
    var email = ""
    
    var login: String {
        get {
            if let charIndex = email.characters.indexOf("@") {
                return email.substringWithRange(email.characters.startIndex...charIndex)
            }
            return ""
        }
    }
    
    init(email: String, name: String) {
        self.email = email
        self.name = name
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let newArray = ["email" : email, "name" : name]
        
        defaults.setObject(newArray, forKey: "user")
    }
}