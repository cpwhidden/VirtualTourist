//
//  APIClient.swift
//  VirtualTourist
//
//  Created by Christopher Whidden on 7/8/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import Foundation
import UIKit

class APIClient: NSObject {
    static let sharedClient = APIClient()
    let sharedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    private override init() {}
    
    func taskForURLsWithParameters(var parameters: [String:String], completionHandler: (urls: [NSURL]?, error: NSError?) -> Void) -> NSURLSessionTask {
        let urlString = APIConstants.baseURL + escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                completionHandler(urls: [], error: error)
            } else {
                var jsonError: NSError? = nil
                let json = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &jsonError) as! NSDictionary
                
                if let results = json["photos"] as? [String:AnyObject],
                    let photos = results["photo"] as? [[String:AnyObject]] {
                        let urls = map(photos) { (photo: [String:AnyObject]) -> NSURL in
                            let urlString = photo[APIConstants.urlExtra] as! String
                            return NSURL(string: urlString)!
                        }
                        completionHandler(urls: urls, error: nil)
                } else {
                    completionHandler(urls: nil, error: jsonError)
                }
            }
        }
        task.resume()
        return task
    }
    
    func taskForURLsWithPinAnnotation(pinAnnotation: PinAnnotation, completionHandler: (urls: [NSURL]?, error: NSError?) -> Void) -> NSURLSessionTask {
        let pin = pinAnnotation.pin
        
        let params = [
            "method" : SearchMethod.searchPhotos,
            "api_key" : APIConstants.apiKey,
            "extras" : APIConstants.urlExtra,
            "format" : APIConstants.jsonFormat,
            "nojsoncallback" : "1",
            "lat" : pinAnnotation.coordinate.latitude.description,
            "long" : pinAnnotation.coordinate.longitude.description
        ]
        
        return taskForURLsWithParameters(params, completionHandler: completionHandler)
    }
    
    func downloadURL(url: NSURL, forPin pin: Pin, completionHandler: (photo: Photo?, error: NSError?)->Void) {
        let request = NSURLRequest(URL: url)
        let task = NSURLSession.sharedSession().downloadTaskWithRequest(request) { url, response, error in
            if let error = error {
                completionHandler(photo: nil, error: error)
            } else {
                let data = NSData(contentsOfURL: url)!
                let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as! String + url.lastPathComponent!
                data.writeToFile(path, atomically: true)
                let dict = ["imagePath" : path, "pin" : pin]
                let photo = Photo(dictionary: dict, context: self.sharedContext)
                completionHandler(photo: photo, error: nil)
            }
        }
    }
    
    func escapedParameters(dictionary: [String:String]) -> String {
        let queryItems = map(dictionary) {
            NSURLQueryItem(name: $0, value: $1)
        }
        let comps = NSURLComponents()
        comps.queryItems = queryItems
        return comps.percentEncodedQuery ?? ""
    }
}

struct APIConstants {
    static let apiKey = "c32f8da39c261a42e12e77299d4179db"
    static let baseURL = "https://api.flickr.com/services/rest/"
    static let urlExtra = "url_m"
    static let jsonFormat = "json"
}

struct SearchMethod {
    static let searchPhotos = "flickr.photos.search"
    static let maxReturnedPhotos = 4000
    static let perPage = 21
    
}