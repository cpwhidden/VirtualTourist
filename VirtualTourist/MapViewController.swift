//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Christopher Whidden on 7/8/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tapToDeleteLabel: UILabel!
    @IBOutlet weak var labelBottom: NSLayoutConstraint!
    @IBOutlet weak var labelHeight: NSLayoutConstraint!
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    var editingEnabled = false
    var tempPinAnnotation: PinAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        
        labelBottom.constant = -tapToDeleteLabel.bounds.height
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        longPressGestureRecognizer.addTarget(self, action: "longPressed:")
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: sharedContext())!
        let request = NSFetchRequest(entityName: "Pin")
        let pins = sharedContext().executeFetchRequest(request, error: nil) as! [Pin]
        for pin in pins {
            let pinAnnotation = PinAnnotation(pin: pin)
            pinAnnotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            mapView.addAnnotation(pinAnnotation)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "toggleEdit:")
            tapToDeleteLabel.enabled = true
            UIView.animateWithDuration(0.3) {
                self.labelBottom.constant = 0
                self.tapToDeleteLabel.layoutIfNeeded()
            }
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "toggleEdit:")
            tapToDeleteLabel.enabled = false
            UIView.animateWithDuration(0.3) {
                self.labelBottom.constant = -self.tapToDeleteLabel.bounds.height
                self.tapToDeleteLabel.layoutIfNeeded()
            }
        }
    }

    @IBAction func toggleEdit(sender: AnyObject) {
        if self.editing {
            self.setEditing(false, animated: true)
        } else {
            self.setEditing(true, animated: true)
        }
    }
    
    func longPressed(sender: UILongPressGestureRecognizer) {
        let point = sender.locationInView(sender.view)
        switch sender.state {
        case .Began:
            tempPinAnnotation = mapView.addPinAnnotationAtPoint(point)
        case .Changed:
            tempPinAnnotation!.coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
        case .Cancelled:
            mapView.removeAnnotation(tempPinAnnotation)
            tempPinAnnotation = nil
        default:
            tempPinAnnotation = nil
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        view.animatesDrop = true
        return view
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let annotation = view.annotation as! PinAnnotation
        if editing {
            mapView.removeAnnotation(annotation)
            let pin = annotation.pin
            sharedContext().deleteObject(pin)
        } else {
            performSegueWithIdentifier("PhotosForPin", sender: annotation)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let id = segue.identifier!
        
        switch id {
        case "PhotosForPin":
            let pinAnnotation = sender as! PinAnnotation
            let destination = segue.destinationViewController as! PhotoAlbumViewController
            destination.pinAnnotation = pinAnnotation
        default:
            return
        }
    }
    
    // TODO: persist current map rect
}

extension MKMapView {
    func addPinAnnotationAtPoint(point: CGPoint) -> PinAnnotation {
        let coordinate = self.convertPoint(point, toCoordinateFromView: self)
        let pinAnnotation = addPinAnnotationToCoordinate(coordinate)
        return pinAnnotation
    }
    
    func addPinAnnotationToCoordinate(location: CLLocationCoordinate2D) -> PinAnnotation {
        let pin = Pin(dictionary: ["latitude" : Double(location.latitude), "longitude" : Double(location.longitude)], context: (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext)
        let annotation = PinAnnotation(pin: pin)
        annotation.coordinate = location
        addAnnotation(annotation)
        return annotation
    }
}
