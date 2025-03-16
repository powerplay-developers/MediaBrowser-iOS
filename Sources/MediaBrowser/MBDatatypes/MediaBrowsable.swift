//
//  MediaBrowsable.swift
//  Powerplay
//
//  Created by Gokul Nair on 17/01/24.
//

import UIKit

/*
 MediaBrowser consumes Media which is of MediaBrowsable Type.
 MediaBrowsable needs to be implemented for every new browser which will be introduced.
 */
public protocol MediaBrowsable {
    
    /**
    A unique ID, which is stored while caching raw data.
     */
    var mediaId: String? { get }
    
    /**
    Placeholder image for the browser to use when error occurs
     */
    var placeHolderImage: UIImage? { get set }
    
    /**
    Remarks added against the media
     */
    var metaData: String? { get set }
    
    /**
    media is selected or not
     */
    var isSelected: Bool { get set }
    
    /**
    Method which converts raw media to Media Browsable Type
     */
    func transformToBrowsableMedia() -> MBMediaType?
}
