//
//  Picture.swift
//  VirtualTourist
//
//  Created by Christopher Whidden on 7/8/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)

class Photo: NSManagedObject {
    @NSManaged var imagePath: String
    @NSManaged var pin: Pin?
    
    struct Keys {
        static let imagePath = "imagePath"
        static let pin = "pin"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        imagePath = dictionary[Keys.imagePath] as! String
        pin = dictionary[Keys.pin] as? Pin
        context.save(nil)
    }
    
    deinit {
        // TODO: remove file at imagePath
    }
}