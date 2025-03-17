//
//  MBPanZoomImageView.swift
//  Powerplay
//
//  Created by Gokul Nair on 30/01/24.
//

import UIKit

/*
 MBPanZoomImageView is the default image view which PhotoBrowser uses. This view hold the capability to zoom in and zoom out.
 
 Along with this it has double tap gesture detection to Zoom in and out.
 */
class MBPanZoomImageView: UIScrollView {
    
    lazy var imageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    /// Image Zoom Toggling
    var isImageZoomEnabled: Bool = true {
        didSet {
          maximumZoomScale = isImageZoomEnabled ? 3 : 1
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        addViews()
        configure()
        layoutConstraints()
        addTarget()
        
    }
    
    private func addViews() {
        addSubview(imageView)
    }
    
    private func configure() {
        // Additional configuration for the scroll view
        minimumZoomScale = 1
        maximumZoomScale = 3
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    private func layoutConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func addTarget() {
        delegate = self
        
        // Double-tap gesture for zooming
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapRecognizer)
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if zoomScale == 1 {
            setZoomScale(2, animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension MBPanZoomImageView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
