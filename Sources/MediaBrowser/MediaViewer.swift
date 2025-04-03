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
        view.delegate = self
        return view
    }()
    
    private lazy var leftSwipeButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "left-chevron-pdf", in: Bundle.module, compatibleWith: nil), for: .normal)
        btn.addTarget(self, action: #selector(didTapOnLeftSwipeButton), for: .touchUpInside)
        return btn
    }()
    
    private lazy var rightSwipeButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "right-chevron-pdf", in: Bundle.module, compatibleWith: nil), for: .normal)
        btn.addTarget(self, action: #selector(didTapOnRightSwipeButton), for: .touchUpInside)
        return btn
    }()
    
    override func addViews() {
        self.view.backgroundColor = .black
        
        self.view.addSubview(contentStack)
        self.view.addSubview(leftSwipeButton)
        self.view.addSubview(rightSwipeButton)
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
        
        NSLayoutConstraint.activate([
            leftSwipeButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            leftSwipeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            leftSwipeButton.widthAnchor.constraint(equalToConstant: 32),
            leftSwipeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        NSLayoutConstraint.activate([
            rightSwipeButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            rightSwipeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            rightSwipeButton.widthAnchor.constraint(equalToConstant: 32),
            rightSwipeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    /// Left Swipe Button action
    @objc private func didTapOnLeftSwipeButton() {
        
        if selectedIndex > 0 {
            
            HapticManager.shared.giveLightImpactFeedback()
            
            self.storeInSessionBrowser(index: (selectedIndex - 1), shouldReloadPager: true)
        }
    }
    
    /// Right Swipe Button action
    @objc private func didTapOnRightSwipeButton() {
        
        if selectedIndex < (toBrowseMediaTypes.count - 1) {
            
            HapticManager.shared.giveLightImpactFeedback()
            
            self.storeInSessionBrowser(index: (selectedIndex + 1), shouldReloadPager: true)
        }
        
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
                if shouldShowAnnotations() {
                    menuChildren.append(editAction)
                }
                break
            default: break
            }
        }
        
        let menu = UIMenu(title: "", children: menuChildren)
        self.browserOptionsButton.menu = menu
    }
    
    override func toggleNavBarWithAnimation() {
        super.toggleNavBarWithAnimation()
        
        if descriptionView.alpha == 1.0 {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.descriptionView.alpha = 0.0
                self?.leftSwipeButton.isHidden = true
                self?.rightSwipeButton.isHidden = true
            }) { [weak self] _ in
                self?.descriptionView.isHidden = true
            }
        } else if let comment = media[safeIndex: selectedIndex]?.metaData, !comment.isBlank() {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.descriptionView.alpha = 1.0
                self?.leftSwipeButton.isHidden = false
                self?.rightSwipeButton.isHidden = false
            }) { [weak self] _ in
                self?.descriptionView.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.leftSwipeButton.isHidden = false
                self?.rightSwipeButton.isHidden = false
            }
        }
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

extension MediaViewer: DescriptionViewDelegate {
    
    func descriptionViewDidTap(_ isHidden: Bool) {
        if !isHidden {
            UIView.animate(withDuration: 0.5, animations: {
                self.contentStack.transform = CGAffineTransform(translationX: 0, y: -50)
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.contentStack.transform = .identity
            })
        }
    }
}
