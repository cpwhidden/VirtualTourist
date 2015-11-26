//
//  PhotoViewController.swift
//  VirtualTourist
//
//  Created by Christopher Whidden on 7/8/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var incompleteActivityIndicator: UIActivityIndicatorView!
    
    let spacing: CGFloat = 6.0
    let columns = 3
    var pinAnnotation: PinAnnotation?
    var photos: [Photo]?
    var photoStatus = PhotosStatus.Incomplete
    
    enum PhotosStatus {
        case Incomplete
        case Done
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        // Do any additional setup after loading the view.
        
        if let pinAnnotation = pinAnnotation {
            let region = MKCoordinateRegionMake(pinAnnotation.coordinate, MKCoordinateSpanMake(0.4, 0.4))
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(pinAnnotation)
            photos = pinAnnotation.pin.pictures
            if photos!.count == 0 {
                photoStatus = .Incomplete
                incompleteActivityIndicator.startAnimating()
                incompleteActivityIndicator.hidden = false
                retrieveURLsForPinAnnotation(pinAnnotation)
            } else {
                photoStatus = .Done
                incompleteActivityIndicator.stopAnimating()
                incompleteActivityIndicator.hidden = true
                collectionView.reloadData()
            }
        }
    }
    
    func retrieveURLsForPinAnnotation(pinAnnotation: PinAnnotation) {
        APIClient.sharedClient.taskForURLsWithPinAnnotation(pinAnnotation) { urls, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "Could not retrieve photos", message: "Photos cannot be retrieved at this time", preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.photoStatus = .Done
                    self.incompleteActivityIndicator.stopAnimating()
                    self.incompleteActivityIndicator.hidden = true
                    self.collectionView.reloadData()
                }
            } else {
                for (_, url) in (urls!).enumerate() {
                    let docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
                    let path = "/" + pinAnnotation.pin.latitude.description.stringByReplacingOccurrencesOfString(".", withString: "_", options: .LiteralSearch, range: nil) + "-" + pinAnnotation.pin.longitude.description.stringByReplacingOccurrencesOfString(".", withString: "_", options: .LiteralSearch, range: nil) + "-" + url.lastPathComponent!
                    let dict = ["imagePath" : path, "pin" : pinAnnotation.pin]
                    let photo = Photo(dictionary: dict, context: sharedContext())
                    APIClient.sharedClient.downloadImageURL(url, toPath: (docPath + path)) { success, error in
                        dispatch_async(dispatch_get_main_queue()) {
                            if error != nil {
                                sharedContext().deleteObject(photo)
                                do {
                                    try sharedContext().save()
                                } catch _ {
                                }
                            } else {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.photoStatus = .Done
                    self.incompleteActivityIndicator.stopAnimating()
                    self.incompleteActivityIndicator.hidden = true
                    self.collectionView.reloadData()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch photoStatus {
        case .Incomplete:
            noImageLabel.hidden = true
            return 0
        case .Done:
            let photos = pinAnnotation?.pin.pictures
            if let cellCount = photos?.count where cellCount > 0 {
                noImageLabel.hidden = true
                return cellCount
            } else {
                noImageLabel.hidden = false
                return 0
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        let docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        let imagePath = pinAnnotation?.pin.pictures[indexPath.row].imagePath
        if let imagePath = imagePath,
           let image = UIImage(contentsOfFile: (docPath + imagePath)) {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.hidden = true
            cell.imageView.image = image
        } else {
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidden = false
            cell.imageView.image = nil
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let spaces = CGFloat(2 * columns)
        let width = (collectionView.bounds.width - (spacing * spaces)) / CGFloat(columns)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        cell.alpha = 0.4
        trashButton.enabled = true
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        cell.alpha = 1.0
        if collectionView.indexPathsForSelectedItems() != nil {
            trashButton.enabled = false
        }
    }
    

    @IBAction func refresh(sender: UIBarButtonItem) {
        photoStatus = .Incomplete
        incompleteActivityIndicator.startAnimating()
        incompleteActivityIndicator.hidden = false
        if let indexPaths = collectionView.indexPathsForSelectedItems() {
            for index in indexPaths {
                collectionView.deselectItemAtIndexPath(index, animated: true)
                collectionView(collectionView, didDeselectItemAtIndexPath: index)
            }
        }
        for photo in pinAnnotation!.pin.pictures {
            sharedContext().deleteObject(photo)
        }
        collectionView.reloadData()
        retrieveURLsForPinAnnotation(pinAnnotation!)
    }
    
    
    @IBAction func deleteSelectedPhotos(sender: UIBarButtonItem) {
        while let index = collectionView.indexPathsForSelectedItems()?.first {
            let row = index.row
            let photo = pinAnnotation?.pin.pictures[row]
            sharedContext().deleteObject(photo!)
            do {
                try sharedContext().save()
            } catch _ {
            }
            collectionView.deleteItemsAtIndexPaths([index])
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
