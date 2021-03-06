//
//  Layout.swift
//  wcViewer
//
//  Created by William Snook on 3/8/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit

protocol LayoutDelegate {

    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath,
        withWidth:CGFloat) -> CGFloat

}

class Layout: UICollectionViewLayout {
    
    var delegate: LayoutDelegate!
    
    var numberOfColumns = 2
    var cellPadding: CGFloat = 4.0

    private var cache = [UICollectionViewLayoutAttributes]()

    private var contentHeight: CGFloat  = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }

    // CollectionView Layout delegate
    override func prepareLayout() {

		cache.removeAll()

		let columnWidth = contentWidth / CGFloat(numberOfColumns)
		var xOffset = [CGFloat]()
		for column in 0 ..< numberOfColumns {
			xOffset.append(CGFloat(column) * columnWidth )
		}
		var column = 0
		var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)

		var offset = true
		contentHeight = 0.0
		for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
			
			let indexPath = NSIndexPath(forItem: item, inSection: 0)

			let width = columnWidth - cellPadding * 2
			let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath,
				withWidth:width)
			let height = cellPadding +  photoHeight + cellPadding
			if offset && ( column == 1 ) {
				offset = false
				yOffset[column] = height / 2.0
			}
			let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
			let insetFrame = CGRectInset(frame, cellPadding, cellPadding)

			let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
			attributes.frame = insetFrame
			cache.append(attributes)

			contentHeight = max(contentHeight, CGRectGetMaxY(frame))
			yOffset[column] = yOffset[column] + height

			column = column >= (numberOfColumns - 1) ? 0 : ++column
		}
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

}