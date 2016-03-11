//
//  Network.swift
//  wcViewer
//
//  Created by William Snook on 3/10/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import Alamofire


typealias JokeBlock = ( UIImageView?, Int ) -> ()


class Network {
    
    class func getImageData( jokesReturn: JokeBlock ) {
        print( "getJokeData" )
        
        // Get dates from start date
//        Alamofire.request(.GET, "http://www.billsnook.com/xperimentl/jotd/json-text.php" , parameters: nil)
//            .responseJSON { response in
//                var json: JSON?
//                switch response.result {
//                case .Success:
//                    if let value = response.result.value {
////                        print( "Value: \(value)")
//                        json = JSON(value)
//                        print( "JSON:\n\(json)" )
//                    } else {
//                        print( "Problem: response value not found" )
//                    }
//                case .Failure(let error):
//                    print( "URLRequest failure: \(error)" )
//                    print( response.result.value )
//                }
//                jokesReturn( json, jidx )
//        }
        
    }
    
}
