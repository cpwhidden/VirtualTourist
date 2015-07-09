//
//  Picture.swift
//  VirtualTourist
//
//  Created by Christopher Whidden on 7/8/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import Foundation
import CoreData

@objc class Photo: NSManagedObject {
    @NSManaged var imageData: NSData
    @NSManaged var pin: Pin
}