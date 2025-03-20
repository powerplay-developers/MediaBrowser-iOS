//
//  MediaViewer.swift
//  MediaBrowser
//
//  Created by Adarsh   on 15/03/25.
//

import UIKit

public protocol MediaViewerDelegate: AnyObject {
    func mediaViewer(_ mediaViewer: MediaViewer, didTapEditButtonAt index: Int)
    func mediaViewer(_ mediaViewer: MediaViewer, willDismissWith selectedIndex: Int)
}

@available(iOS 13.0, *)
public class MediaViewer: MediaBrowser {
    
    public weak var viewerDelegate: MediaViewerDelegate?
    
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
    
    @available(iOS 14.0, *)
    override func didTapOnBrowserOptionButton(sender: UIButton) {
        
        let shareAction = UIAction(title: MBOperations.Share.rawValue) { action in
            
            if let cachedData = self.inSessionBrowser?.cachedData {
                
                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let self else { return }
                    
                    cachedData.generateShareableData { [weak self] (items, status, error) in
                        
                        self?.handleLoader(withStatus: status)
                        
                        if let items {
                            self?.showShareSheet(withItems: [items])
                        }
                        
                        if let error {
                            self?.showAlert(title: "Error", message: error.localizedDescription)
                        }
                    }
                }
            } else {
                
                self.showAlert(title: "Warning", message: "The media is currently undergoing rendering; please wait for the data to be processed before sharing.")
            }
            
        }
        
        let editAction = UIAction(title: MBOperations.Edit.rawValue) { action in
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.viewerDelegate?.mediaViewer(self, didTapEditButtonAt: self.selectedIndex)
            }
        }
        
        var menuChildren: [UIAction] = []
        
        browserTools.forEach { tool in
            
            switch tool {
            case .Share:
                menuChildren.append(shareAction)
                break
            case .Edit:
                menuChildren.append(editAction)
                break
            default: break
            }
        }
        
        let menu = UIMenu(title: "", children: menuChildren)
        self.browserOptionsButton.menu = menu
    }
    
    override func didTapOnDismissButton() {
        self.viewerDelegate?.mediaViewer(self, willDismissWith: selectedIndex)
        self.dismiss(animated: true)
    }
    
    override func storeInSessionBrowser(index: Int, shouldReloadPager: Bool = false) {
        super.storeInSessionBrowser(index: index, shouldReloadPager: shouldReloadPager)
        if let comment = media[safeIndex: index]?.metaData, !comment.isBlank() {
            descriptionView.isHidden = false
            descriptionView.setDescription(comment)
        } else {
            descriptionView.isHidden = true
            descriptionView.setDescription("")
        }
    }
}
