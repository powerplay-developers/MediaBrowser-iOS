//
//  MediaBrowserDelegate.swift
//  Powerplay
//
//  Created by Gokul Nair on 30/01/24.
//

import Foundation


/*
 MediaBrowserDelegate, used to delegate various information to the MediaBrowser presenter View.
 */
@available(iOS 13.0, *)
public protocol MediaBrowserDelegate: AnyObject {
    /**
     Tells the delegate that the browser started swiping browsers
     
     Note: This delegate is triggered at first launch also
     
        - Parameter index: the index of the new browser
     */
    func mediaBrowserDidSwipe(withIndex index: Int, browser: MediaBrowser)
    
    /**
     Tells the delegate that the browser will dismiss
     
         - Parameter index: the index of the current browser
     */
    func willDismissMediaBrowserAtPageIndex(withIndex index: Int, browser: MediaBrowser)
    
    /**
     Tells the delegate that the controls view toggled visibility
          
          - Parameter browser: reference to the calling MediaBrowser
          - Parameter hidden: the status of visibility control
     */
    func mediaBrowserControlVisibilityToggled(browser: MediaBrowser, hidden: Bool)
    
    /**
     Tells the delegate that the medias are ready for upload
          
          - Parameter browsers: reference to all the Media
     */
    func didFinishBrowsingMedia(browsers: [MediaBrowsable])
    
    /**
     Tells the delegate that the medias are ready for upload
          
          - Parameter browser: reference to the Media
     */
    func didTapAnnotations(browser: MediaBrowsable)
}

@available(iOS 13.0, *)
extension MediaBrowserDelegate {
    
    func mediaBrowserDidSwipe(withIndex index: Int, browser: MediaBrowser) { }
    
    func willDismissMediaBrowserAtPageIndex(withIndex index: Int, browser: MediaBrowser) { }
    
    func mediaBrowserControlVisibilityToggled(browser: MediaBrowser, hidden: Bool) { }
    
    func didFinishBrowsingMedia(browsers: [MediaBrowsable]) { }
    
    func didTapAnnotations(browser: MediaBrowsable) { }
}
