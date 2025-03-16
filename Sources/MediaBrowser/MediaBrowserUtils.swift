//
//  MediaBrowserUtils.swift
//  Powerplay
//
//  Created by Gokul Nair on 12/01/24.
//

import UIKit
import MobileCoreServices


public class MediaBrowserUtils {
    
    static let shared = MediaBrowserUtils()
    
    /// Singleton class creation
    private init() { }
    
    /* URL needs to be classified according to the media type they are. This method classifies them on the basis of path extension. If path extension classification fails then MobileCoreServices are used to identify the type. */
    
    /// Media URL Classifier
    /// - Parameter url: Media URL to classify
    /// - Returns: classified URL media(MBMediaType) type
    func classifyMediaType(url: String) -> MBMediaType? {
        
        guard let url = URL(string: url) else { return nil }
        
        // Get the file extension from the URL
        let fileExtension = url.pathExtension.lowercased()
        
        // Check for common image file extensions
        let photoTypes = MBPhotoType.allCases.map({ $0.rawValue })
        if photoTypes.contains(fileExtension) {
            return .Photo(url: url)
        }
        
        // Check for common video file extensions
        let videoTypes = MBVideoType.allCases.map({ $0.rawValue })
        if videoTypes.contains(fileExtension) {
            return .Video(url: url)
        }
        
        // Check for common document file extensions
        let documentTypes = MBDocumentType.allCases.map({ $0.rawValue })
        if documentTypes.contains(fileExtension) {
            return .Documents(url: url)
        }
        
        // If the file extension is not recognized, try determining the content type using MobileCoreServices
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?.takeRetainedValue() {
            let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() as String?
            
            let supportedDocumentMimeType = MBDocumentType.allCases.map({ $0.mimeType })
            
            if let mimeType = mimeType {
                
                if mimeType.hasPrefix("image") {
                    return .Photo(url: url)
                }
                
                else if mimeType.hasPrefix("video") {
                    return .Video(url: url)
                }
                
                else if supportedDocumentMimeType.contains(mimeType) {
                    return .Documents(url: url)
                }
            }
        }
        
        // Default case if the type cannot be determined, then use the URL to render on webView
        return .Web(url: url)
    }
    
    /// Media Browser, Networking method
    /// - Parameters:
    ///   - url: URL to hit during the network call
    ///   - completion: Data for the corresponding URL, with error if occurred
    func fetchURLData(url: URL, completion: @escaping((Data?, Error?) -> ())) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard !url.isFileURL else {
                let fileData = MediaBrowserFileManager.shared.get(fileUrl: url)
                completion(fileData, nil)
                return
            }
            
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode == 200{
                completion(data, nil)
                
            } else {
                completion(nil, nil)
            }
        }
        
        task.resume()
    }
    
    /// Audio/Video format analyser
    /// - Parameter url: url to analyse for AV format
    /// - Returns: MBVideoType enum, which holds format and output type
    func getAVFormat(url: URL) -> MBVideoType? {
        
        let fileExtension = url.pathExtension.lowercased()
        
        let videoTypes = MBVideoType.allCases.map({ $0.rawValue })
        
        let avFormat = videoTypes.first(where: { $0.contains(fileExtension) }) ?? ""
        
        guard let videoType = MBVideoType(rawValue: avFormat) else { return nil }
        
        return videoType
    }
    
    /// Document format analyser
    /// - Parameter url: url to analyse for doc format
    /// - Returns: MBDocumentType enum, which holds format and mime type
    func getDocumentType(url: URL) -> MBDocumentType? {
        
        let fileExtension = url.pathExtension.lowercased()
        
        let documentTypes = MBDocumentType.allCases.map({ $0.rawValue })
        
        let documentType = documentTypes.first(where: { $0.contains(fileExtension) }) ?? ""
        
        return MBDocumentType(rawValue: documentType)
    }
}


// MARK: - Raw Data Converters
extension MediaBrowserUtils {
    
    /// URL String helper to convert any url to MediaBrowsable type
    public static func mediaBrowsable(_ urlString: String, holderImage: UIImage? = nil, description: String? = nil) -> MediaBrowsable {
        return MBMediaUrl(url: urlString, placeHolderImage: holderImage, metaData: description)
    }
    
    /// Raw Data helper to convert any data to MediaBrowsable type
    public static func mediaBrowsable(_ data: Data, holderImage: UIImage? = nil, description: String? = nil) -> MediaBrowsable {
        return MBImageData(data: data, placeHolderImage: holderImage, metaData: description)
    }
    
    /// UIImage helper to convert any image to MediaBrowsable type
    public static func mediaBrowsable(_ image: UIImage, mediaId: String? = nil, holderImage: UIImage? = nil, description: String? = nil) -> MediaBrowsable {
        return MBImage(id: mediaId, image: image, placeHolderImage: holderImage, metaData: description)
    }
}

