//
//  PhotoViewController.swift
//  VirtualTourist
//
//  Created by Christopher Whidden on 7/8/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImageLabel: UILabel!
    
    let spacing: CGFloat = 6.0
    let columns = 3
    var pinAnnotation: PinAnnotation?
    var photos: [Photo]?
    var photoStatus = PhotosStatus.Unknown
    
    enum PhotosStatus {
        case Unknown
        case Some(Int)
        case None
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        // Do any additional setup after loading the view.
        
        if let pinAnnotation = pinAnnotation {
            let region = MKCoordinateRegionMake(pinAnnotation.coordinate, MKCoordinateSpanMake(0.4, 0.4))
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(pinAnnotation)
            photos = pinAnnotation.pin.pictures
            if photos!.count == 0 {
                retrieveURLsForPinAnnotation(pinAnnotation)
            }
        }
    }
    
    func retrieveURLsForPinAnnotation(pinAnnotation: PinAnnotation) {
        APIClient.sharedClient.taskForURLsWithPinAnnotation(pinAnnotation) { urls, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.photoStatus = .None
                    let alert = UIAlertView(title: "Could not retrieve photos", message: "Photos cannot be retrieved at this time", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    self.collectionView.reloadData()
                }
            } else {
                var count = urls!.count
                for (index, url) in enumerate(urls!) {
                    let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as! String + pinAnnotation.pin.latitude.description + "-" + pinAnnotation.pin.longitude.description + "-" + url.lastPathComponent!
                    let dict = ["imagePath" : path, "pin" : pinAnnotation.pin]
                    let photo = Photo(dictionary: dict, context: sharedContext())
                    APIClient.sharedClient.downloadImageURL(url, toPath: path) { success, error in
                        if error != nil {
                            count--
                            sharedContext().deleteObject(photo)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    if count > 0 {
                        self.photoStatus = .Some(count)
                    } else {
                        self.photoStatus = .None
                    }
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
        case .Unknown:
            noImageLabel.hidden = false
            return 0
        case .None:
            noImageLabel.hidden = true
            return 0
        case let .Some(i):
            return i
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! UICollectionViewCell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
