//
//  Person.swift
//  NamesToFaces
//
//  Created by a on 12/1/15.
//  Copyright © 2015 bromodachi. All rights reserved.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }

}
