//
//  MBImageData.swift
//  Powerplay
//
//  Created by Gokul Nair on 17/01/24.
//

import UIKit


// MBImageData is the Data format which MediaBrowser uses to render Data based media.
class MBImageData: MediaBrowsable {
    
    var isSelected: Bool = false
    
    var metaData: String?
    
    var data: Data
    
    var mediaId: String?
    
    var placeHolderImage: UIImage?
    
    init(data: Data, placeHolderImage: UIImage? = UIImage()) {
        self.data = data
        self.placeHolderImage = placeHolderImage
    }
    
    /// Transforms the MediaBrowsable data to MBMediaType
    func transformToBrowsableMedia() -> MBMediaType? {
        return  .Image(image: UIImage(data: data) ?? UIImage())
    }
}

