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
                
                // Download urls for pin

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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TestCell", forIndexPath: indexPath) as! UICollectionViewCell
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
