//
//  CustomLocation.swift
//  GeoTrackingUser
//
//  Created by Gunwoo Lee on 12/4/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation

struct CustomLocation {
    var longitude : Double
    var latitude : Double
    var altitude : Double
    var name : String
    init (_ longitude : Double, _ latiitude : Double, _ altitude : Double, _ name : String ){
        self.longitude=longitude
        self.latitude=latiitude
        self.altitude=altitude
        self.name=name
    }
}
