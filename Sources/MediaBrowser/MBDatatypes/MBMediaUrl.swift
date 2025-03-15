//
//  MBMediaUrl.swift
//  Powerplay
//
//  Created by Gokul Nair on 17/01/24.
//

import UIKit


// MBMediaUrl is the URL format which MediaBrowser uses to render URL based media.
class MBMediaUrl: MediaBrowsable {
    
    var isSelected: Bool = false
    
    var metaData: String?
    
    var url: String
    
    var mediaId: String?
    
    var placeHolderImage: UIImage?
    
    init(url: String, placeHolderImage: UIImage? = UIImage()) {
        self.url = url
        self.placeHolderImage = placeHolderImage
    }
    
    /// Transforms the MediaBrowsable data to MBMediaType
    func transformToBrowsableMedia() -> MBMediaType? {
        return MediaBrowserUtils.shared.classifyMediaType(url: url)
    }
}

