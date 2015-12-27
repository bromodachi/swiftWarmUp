//
//  Capital.swift
//  Map
//
//  Created by a on 12/27/15.
//  Copyright © 2015 bromodachi. All rights reserved.
//

import UIKit

import MapKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate:CLLocationCoordinate2D, info:String){
    
        self.title = title
        self.coordinate  = coordinate
        self.info = info
    }

}
