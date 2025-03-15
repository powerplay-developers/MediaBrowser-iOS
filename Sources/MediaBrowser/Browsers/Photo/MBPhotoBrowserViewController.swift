//
//  MBPhotoBrowserViewController.swift
//  Powerplay
//
//  Created by Gokul Nair on 12/01/24.
//

import UIKit

/*
 Photo/Image based media browsing is done by this browser. The same browser can be used to render an Image based Media also URL based Photo media.
 
 On rendering URL based Media use:
 convenience init(url: URL, placeHolder: UIImage?, localMediaCache: MBCacheable?) {}
 
 On rendering UIImage based Media use:
 convenience init(image: UIImage, placeHolder: UIImage?, localMediaCache: MBCacheable?) {}
 */
@available(iOS 13.0, *)
final class MBPhotoBrowserViewController: MBBrowserBaseViewController {
    
    private lazy var panZoomImageView: MBPanZoomImageView = {
        let img = MBPanZoomImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.isUserInteractionEnabled = true
        img.isImageZoomEnabled = MBConstants.isPhotoZoomEnabled
        return img
    }()
    
    /// Image Rendering Task
    private var imageFetchTask: Task<(), Never>? = nil
    
    
    override init(url: URL?, placeHolder: UIImage?, localMediaCache: MBCacheable?, storagePolicy: MBStoragePolicy) {
        super.init(url: url, placeHolder: placeHolder, localMediaCache: localMediaCache, storagePolicy: storagePolicy)
    }
    
    // For rendering UIImage based Media
    convenience init(image: UIImage, placeHolder: UIImage?, localMediaCache: MBCacheable?, storagePolicy: MBStoragePolicy) {
        
        self.init(url: nil, placeHolder: placeHolder, localMediaCache: localMediaCache, storagePolicy: storagePolicy)
        
        self.panZoomImageView.imageView.image = image
        /*
         This init will be used when UIIMage is either in assets or a url is already rendered as UIImage. In this scenario no caching required since its already cached.
         */
        self.delegate?.didFinishRenderingMedia(withIndexPath: browserIndex, cachedData: MBCacheableImage(cacheId: "", image: image), isCachingRequired: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let mediaUrl {
            checkIfPreCached(url: mediaUrl)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// Canceling the task to avoid unnecessary task execution
        self.imageFetchTask?.cancel()
    }
    
    override func addViews() {
        self.view.backgroundColor = .black
        self.view.addSubview(panZoomImageView)
    }
    
    override func layoutConstraints() {
        
        NSLayoutConstraint.activate([
            panZoomImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            panZoomImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            panZoomImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            panZoomImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
    }
    
    override func addTarget() {
        
    }
    
    /// Checks for PreCached data, and if preCached data exists then consumes it if not then network calls are made to render the data
    private func checkIfPreCached(url: URL) {
        
        /// If Cached
        if let localMediaCache, let cachedImage = localMediaCache as? MBCacheableImage {
            
            self.panZoomImageView.imageView.contentMode = .scaleAspectFit
            self.panZoomImageView.imageView.image = cachedImage.image
            
        } else {
            
            /// Safety check
            self.hideErrorSheet()
            
            /// High priority task, since we want the image to be rendered as soon as possible
            self.imageFetchTask = Task(priority: .high) { [weak self] in
                
                guard let self else { return }
                
                self.loader.startLoading()
                
                await self.panZoomImageView.imageView.loadImageURL(url: url, contentMode: .scaleAspectFit, placeHolderImage: nil) { [weak self] (image, error) in
                    
                    self?.loader.stopLoading()
                    
                    /// Checks if task is cancelled 
                    guard let self, !Task.isCancelled else { return }
                    
                    /// Catching Image
                    if let image {
                        self.hideErrorSheet()
                        let cacheToStore = MBCacheableImage(cacheId: "\(url)", image: image)
                        self.localMediaCache = cacheToStore
                        self.delegate?.didFinishRenderingMedia(withIndexPath: self.browserIndex, cachedData: cacheToStore, isCachingRequired: !url.isFileURL)
                    }
                    
                    /// Error case handled, since the extension method set Placeholder image is nil
                    if let error {
                        
                        handleError(content: .init(errorContent: .init(actionTitle: MBConstants.UITexts.errorActionButtonText, title: MBConstants.UITexts.photoBrowserErrorText, image: MBConstants.Images.photoBrowserErrorImage, uiImage: self.placeHolder, attributedTitle: nil), properties: .init(appSection: self.className)))
                        
                        self.delegate?.didFailRenderingMedia(withIndexPath: self.browserIndex, error: .failedToRenderBrowserData(message: error.localizedDescription))
                        
                    }
                }
            }
            
        }
    }
    
    override func didTapOnAction(errorType: ErrorType) {
        if let mediaUrl {
            checkIfPreCached(url: mediaUrl)
        }
    }
}
