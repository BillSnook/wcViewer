//
//  ViewController.swift
//  wcViewer
//
//  Created by William Snook on 3/8/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UICollectionViewController {

    private let reuseIdentifier = "ImageCell"
    private let sectionInsets = UIEdgeInsets(top: 64.0, left: 5.0, bottom: 5.0, right: 5.0)
    private let downloadQueue = dispatch_queue_create("com.test.wcViewer",nil)

//    var images = Image.allImages()
    var showArray = Array<Dictionary<String,String>>()

    let imageCache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let layout = collectionView?.collectionViewLayout as? Layout {
            layout.delegate = self
        }
        collectionView?.contentInset = sectionInsets
//        collectionView?.registerClass(CustomHeaderView.self, forCellWithReuseIdentifier: "HeaderCell")
        collectionView?.registerClass(CustomHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderCell")
        
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


extension ViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        if kind == UICollectionElementKindSectionHeader {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderCell", forIndexPath: indexPath) as UICollectionReusableView
            cell.backgroundColor = UIColor.orangeColor()
            cell.frame = CGRect(x: 0.0, y: 0.0, width: collectionView.frame.size.width, height: 44.0)
            return cell
//        }
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