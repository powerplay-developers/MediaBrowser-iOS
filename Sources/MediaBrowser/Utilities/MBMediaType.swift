//
//  MediaBrowserEnums.swift
//  Powerplay
//
//  Created by Gokul Nair on 12/01/24.
//

import UIKit
import AVFoundation

// MARK: - Types of format that Media Browser supports.
public enum MBMediaType {
    case Photo(url: URL)
    case Image(image: UIImage)
    case Video(url: URL)
    case Documents(url: URL)
    case Web(url: URL)
    
    var mediaExtension: String? {
        switch self {
        case .Photo(let url):
            return url.pathExtension
        case .Image(let image):
            return image.imageType?.rawValue
        case .Video(let url):
            return url.pathExtension
        case .Documents(let url):
            return url.pathExtension
        case .Web(_):
            return nil
        }
    }
}

// MARK: - Types of photo format that Media Browser supports.
enum MBPhotoType: String, CaseIterable {
    case jpg
    case jpeg
    case png
    case gif
}

// MARK: - Types of video format that Media Browser supports.
enum MBVideoType: String, CaseIterable {
    case mp4
    case mov
    
    var outputType: AVFileType {
        switch self {
        case .mp4:
            return .mp4
        case .mov:
            return .mov
        }
    }
}

// MARK: - Types of document format that Media Browser supports.
enum MBDocumentType: String, CaseIterable {
    case html
    case docx
    case doc
    case odt
    case md
    case txt
    case xml
    case csv
    case pdf
    
    var mimeType: String {
        switch self {
        case .html:
            "text/html"
        case .docx:
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .doc:
            "application/msword"
        case .odt:
            "application/vnd.oasis.opendocument.text"
        case .md:
            "text/markdown"
        case .txt:
            "text/plain"
        case .xml:
            "application/xml"
        case .csv:
            "text/csv"
        case .pdf:
            "application/pdf"
        }
    }
}

// MARK: - Browser Operations
public enum MBOperations: String {
    case Share = "Share"
    case Annotations = "Annotations"
    case Edit = "Edit"
    case Delete = "Delete"
}

// MARK: - Browser Upload State
enum MBUploadStatus {
    case Inprogress
    case Failed
    case Completed
}

// MARK: - Browser Write State
enum MBFileOperationStatus {
    case Inprogress
    case Failed
    case Completed
}

// MARK: - Browser Caching Policy type

// Media Browser supports three types of Media Storage Policy.
public enum MBStoragePolicy {
    /*
     InMemory storage policy stores/caches the rendered media in Browser class. Thus the data will get disposed when Media Browser session is ended.
     
     Such kind of policy is used when temporary browsing is required. Here data is captured till the browser session.
     */
    case InMemory
    
    /*
     UsingNSCache storage policy caches the rendered media for entire app life cycle. Thus the data will get disposed when the app is killed.
     
     Such kind of policy is used when there is frequent demand of media browsing required.
     */
    case UsingNSCache
    
    /*
     DiskStorage storage policy caches the rendered media until disk gets out of space or the disk is not cleared. Thus the data will not get disposed even when the app is killed.
     
     Such kind of policy is best used when there are constant images to be rendered repetitively.
     */
    case DiskStorage
}
