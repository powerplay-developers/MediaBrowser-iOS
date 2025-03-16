//
//  MediaViewer.swift
//  MediaBrowser
//
//  Created by Adarsh   on 15/03/25.
//

import UIKit

@available(iOS 13.0, *)
public class MediaViewer: MediaBrowser {
    
    private lazy var descriptionView: DescriptionView = {
        let view = DescriptionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.5)
        return view
    }()
    
    override func addViews() {
        self.view.backgroundColor = .black
        
        self.view.addSubview(contentStack)
        self.view.addSubview(descriptionView)
        contentStack.addArrangedSubViews([upperNavBar, pageViewControl])
        
        upperNavBar.addSubview(dismissButton)
        upperNavBar.addSubview(browserTitleLabel)
        upperNavBar.addSubview(browserOptionsButton)
    }
    
    override func layoutConstraints() {
        
        NSLayoutConstraint.activate([
            browserTitleLabel.topAnchor.constraint(equalTo: upperNavBar.topAnchor, constant: 16),
            browserTitleLabel.bottomAnchor.constraint(equalTo: upperNavBar.bottomAnchor, constant: -16),
            browserTitleLabel.leadingAnchor.constraint(equalTo: upperNavBar.leadingAnchor, constant: 48),
            browserTitleLabel.trailingAnchor.constraint(equalTo: upperNavBar.trailingAnchor, constant: -48)
        ])
        
        NSLayoutConstraint.activate([
            dismissButton.widthAnchor.constraint(equalToConstant: 48),
            dismissButton.heightAnchor.constraint(equalToConstant: 48),
            dismissButton.leadingAnchor.constraint(equalTo: upperNavBar.leadingAnchor, constant: 8),
            dismissButton.centerYAnchor.constraint(equalTo: upperNavBar.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            browserOptionsButton.widthAnchor.constraint(equalToConstant: 48),
            browserOptionsButton.heightAnchor.constraint(equalToConstant: 48),
            browserOptionsButton.trailingAnchor.constraint(equalTo: upperNavBar.trailingAnchor, constant: -8),
            browserOptionsButton.centerYAnchor.constraint(equalTo: upperNavBar.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            upperNavBar.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            descriptionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            descriptionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            descriptionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override func didTapOnDismissButton() {
        self.delegate?.willDismissMediaBrowserAtPageIndex(withIndex: selectedIndex, browser: self)
        self.dismiss(animated: true)
    }
    
    override func storeInSessionBrowser(index: Int, shouldReloadPager: Bool = false) {
        super.storeInSessionBrowser(index: index, shouldReloadPager: shouldReloadPager)
        descriptionView.setDescription(media[safeIndex: index]?.metaData ?? "")
    }
}
