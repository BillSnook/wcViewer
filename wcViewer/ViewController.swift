//
//  ViewController.swift
//  wcViewer
//
//  Created by William Snook on 3/8/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    private let reuseIdentifier = "ImageCell"
    private let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    private let downloadQueue = dispatch_queue_create("com.test.wcViewer",nil)
    
    @IBOutlet weak var collectionView: UICollectionView!

    var showArray = Array<Dictionary<String,String>>()

    let imageCache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView?.collectionViewLayout as? Layout {
            layout.delegate = self
        }
        collectionView?.contentInset = sectionInsets
        
        if let URL = NSBundle.mainBundle().URLForResource("shows", withExtension: "json") {
            if let jsonData = NSData(contentsOfURL: URL) {
                do {
                    var jsonDictionary = try NSJSONSerialization.JSONObjectWithData( jsonData, options: NSJSONReadingOptions( rawValue: 0 ) ) as! Dictionary<String, AnyObject>
                        convertToDataSource( jsonDictionary["shows"]! )
                } catch {
                    print( "Data is not JSON: \(jsonData.description)" )
                }
            }
        }

    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let layout = collectionView.collectionViewLayout as? Layout else {
            return
        }
        
        layout.invalidateLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func convertToDataSource( data: AnyObject ) {
        extractData( data )
        collectImages()
    }
    
    func extractData( data: AnyObject ) {
        if let newArray = data as? Array<AnyObject> {
            for item in newArray {
                if let showEntry = item as? Dictionary<String,AnyObject> {
                    if let name = showEntry["name"] as? String {
                        if let images = showEntry["images"] as? Array<Dictionary<String,AnyObject>> {
                            for image in images {
                                if let type = image["type"] as? String {
                                    if type == "SHOW_IMAGE" {
                                        if let url = image["url"] as? String {
                                            let showDict = ["name":name, "url":url]
                                            showArray.append( showDict )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
//        print("showArray: \(showArray.description)")
    }
    
    func collectImages() {
        for item in showArray {
            downloadImage( item )
        }
    }

    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(showItem: Dictionary<String,String>){
//        print("Download Started")
        let url = showItem["url"]!
        if let url = NSURL(string: url ) {
            dispatch_async(downloadQueue) {
                self.getDataFromUrl(url) { (data, response, error) in
                    guard let data = data where error == nil else { return }
                    self.imageCache.setObject(UIImage(data: data)!, forKey: showItem["name"]!)
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
    }
    
}


extension ViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCell
        let item = showArray[indexPath.item]
        if let image = imageCache.objectForKey( item["name"]! ) {
            print("Image size, w: \(image.size.width), h:\(image.size.height)")
            cell.image = image as? UIImage
        } else {
            cell.image = nil
        }
//        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }

}

extension ViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = showArray[indexPath.item]
        if let name = item["name"] {
            let alertController = UIAlertController(title: name, message:
                nil, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Watch Now", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

}

extension ViewController: LayoutDelegate {

    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath,
        withWidth:CGFloat) -> CGFloat {
        let item = showArray[indexPath.item]
        if let image = imageCache.objectForKey( item["name"]! ) {
//            print("Image size, w: \(image.size.width), h:\(image.size.height)")
            let mult = withWidth / image.size.width
            return image.size.height * mult
        } else {
            return 90.0
        }
    }

//    func collectionView(collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//            
//            return CGSize(width: 100, height: 100)
//    }
//
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            
            return sectionInsets
    }
}