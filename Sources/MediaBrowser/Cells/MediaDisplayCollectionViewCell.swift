//
//  MediaDisplayCollectionViewCell.swift
//  MediaBrowser
//
//  Created by Adarsh   on 13/03/25.
//

import UIKit

class MediaDisplayCollectionViewCell: UICollectionViewCell {
    
    static let id = "MediaDisplayCollectionViewCell"
    
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 8
        imgView.layer.masksToBounds = false
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private lazy var videoIndicator: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.image = UIImage(named: "video_indicator_pdf", in: Bundle.module, compatibleWith: nil)
        imgView.tintColor = .white
        imgView.isHidden = true
        return imgView
    }()
    
    private(set) lazy var selectionOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = false
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    private(set) lazy var deleteImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.image = UIImage(named: "delete_icon_pdf", in: Bundle.module, compatibleWith: nil)
        imgView.isHidden = true
        return imgView
    }()
    
    var isCellSelected: Bool = false {
        didSet {
            let selectionBorderWidth = isCellSelected ? 2 : 0
            selectionOverlay.layer.borderWidth = CGFloat(selectionBorderWidth)
            selectionOverlay.isHidden = !isCellSelected
            deleteImageView.isHidden = !isCellSelected
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        layoutConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectionOverlay)
        contentView.addSubview(videoIndicator)
        contentView.addSubview(deleteImageView)
    }
    
    private func layoutConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            selectionOverlay.topAnchor.constraint(equalTo: self.topAnchor),
            selectionOverlay.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            selectionOverlay.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            selectionOverlay.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            videoIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            videoIndicator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            videoIndicator.widthAnchor.constraint(equalToConstant: 20),
            videoIndicator.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            deleteImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            deleteImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            deleteImageView.widthAnchor.constraint(equalToConstant: 30),
            deleteImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(withBrowsable media: MediaBrowsable) {
        if let imageData = media as? MBImage {
            imageView.image = imageData.image
            videoIndicator.isHidden = true
        } else if let videoData = media as? MBMediaUrl {
            imageView.image = videoData.placeHolderImage
            videoIndicator.isHidden = false
        }
        isCellSelected = media.isSelected
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        videoIndicator.isHidden = true
    }
}
