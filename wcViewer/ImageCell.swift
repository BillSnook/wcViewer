//
//  ImageCell.swift
//  wcViewer
//
//  Created by William Snook on 3/8/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!

    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
            }
        }
    }
    
}
