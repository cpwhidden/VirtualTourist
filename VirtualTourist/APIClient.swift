//
//  APIClient.swift
//  VirtualTourist
//
//  Created by Christopher Whidden on 7/8/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import Foundation

class APIClient: NSObject {
    static let sharedClient = APIClient()
    
    private override init() {}
    
    func taskForURLsForPin(pin: Pin, var parameters: [String:String], completionHandler: (urls: [NSURL], error: NSError?) -> Void) -> NSURLSessionTask {
        parameters[Keys.apiKey] = APIConstants.apiKey
        
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
                            let urlString = photo[APIConstants.extras] as! String
                            return NSURL(string: urlString)!
                        }
                }
            }
        }
        task.resume()
        return task
    }
    
    func downloadURLs(urls: [NSURL], toPath path: NSURL, completionHandler: (success: Bool, error: NSError?)->Void) {
        //TODO: Implement
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

struct Keys {
    static let apiKey = "api_key"
}

struct APIConstants {
    static let apiKey = "b4c81eeb1e2969ff84fbf288eaabcbeb"
    static let baseURL = "https://api.flickr.com/services/rest/"
    static let extras = "url_m"
}

struct Methods {
    static let searchPhotos = "flickr.photos.search"
}