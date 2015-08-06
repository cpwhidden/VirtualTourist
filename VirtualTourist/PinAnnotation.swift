//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Christopher Whidden on 8/5/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import UIKit
import MapKit

class PinAnnotation: MKPointAnnotation {
    let pin: Pin
    
    init(pin: Pin) {
        self.pin = pin
    }
}
