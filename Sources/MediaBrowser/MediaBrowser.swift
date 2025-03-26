//
//  MediaBrowserView.swift
//  Powerplay
//
//  Created by Gokul Nair on 12/01/24.
//

import UIKit
import UXPagerView


@available(iOS 13.0, *)
public class MediaBrowser: UIViewController {
    
    private(set) lazy var pageViewControl: UXPagerView = {
        let pagerView = UXPagerView()
        pagerView.delegate = self
        pagerView.set(isTabViewHidden: true)
        pagerView.set(tabBackgroundColor: .black)
        pagerView.set(containerBackgroundColor: .black)
        return pagerView
    }()
    
    private(set) lazy var dismissButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)), for: .normal)
        btn.tintColor = MBConstants.Color.browserTint
        return btn
    }()
    
    private(set) lazy var browserTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 18)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private(set) lazy var browserOptionsButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "three-dots-pdf", in: Bundle.module, compatibleWith: nil), for: .normal)
        btn.tintColor = MBConstants.Color.browserTint
        return btn
    }()
    
    private(set) lazy var upperNavBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var bottomNavBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var descriptionTextField: PaddedTextField = {
        let tf = PaddedTextField(insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.attributedPlaceholder = NSAttributedString(string: "Enter a description...", attributes: [.foregroundColor: UIColor.white])
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 14)
        tf.backgroundColor = .clear
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        tf.addDoneButtonOnKeyboard()
        tf.delegate = self
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return tf
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "chevron_right", in: Bundle.module, compatibleWith: nil)?.withTintColor(.white), for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 62, height: 74)
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.allowsSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(MediaDisplayCollectionViewCell.self, forCellWithReuseIdentifier: MediaDisplayCollectionViewCell.id)
        
        return collectionView
    }()
    
    private(set) lazy var contentStack: UIStackView = {
        let stck = UIStackView()
        stck.translatesAutoresizingMaskIntoConstraints = false
        stck.axis = .vertical
        stck.spacing = 0
        return stck
    }()
    
    lazy var _errorView: MBErrorView = {
        let err = MBErrorView()
        err.delegate = self
        return err
    }()
    
    private lazy var loader: MBLoadingView = {
        let view = MBLoadingView(withParentView: self.view, overlayInsets: UIEdgeInsets(top: CGFloat(MBConstants.Metrics.homeViewAppBarHeight) + 30, left: 0, bottom: 0, right: 0))
        view.setOverlayColor(.clear)
        view.loadingIndicator.color = .black
        view.loadingIndicator.layer.cornerRadius = 4
        return view
    }()
    
    // MARK: - Stored Properties
    
    /// Medias to be browsed by the browser
    private(set) var media: [MediaBrowsable] = [] {
        didSet {
            computeBrowsableData()
        }
    }
    
    /// Set of media types to browse
    private var toBrowseMediaTypes: [MediaBrowserData] = []
    
    /// Set first launch browser index
    private(set) var selectedIndex: Int = 0
    
    /// Flag to log current in session browser
    private(set) var inSessionBrowser: MediaBrowserData?
    
    /// NavBar Visibility Toggle
    private var isToolBarVisible: Bool = true
    
    /// Available Browser Tools
    private(set) var browserTools: [MBOperations] = []
    
    /// Default PlaceHolder Image for all browsers
    /*
     If you want to add specific image for each browser, then add the place holder image while converting, raw data to MediaBrowsable type.
     */
    private var placeHolderImage: UIImage?
    
    /// MediaBrowser Storage policy
    /*
     Supported Types: InMemory, UsingNSCache, DiskStorage
     (Check MBStoragePolicy for more details)
     */
    private var storagePolicy: MBStoragePolicy
    
    /// MediaBrowser View delegation
    public weak var delegate: MediaBrowserDelegate?
    
    /// Parent class nav bar visibility flag
    private var isParentNavigationBarHidden = false
    
    /// Bottom Contstraint for the view
    private var bottomConstraint: NSLayoutConstraint?
    
    /// Keyboard visbility Contstraint for the view
    private var isKeyboardVisible: Bool = false
    
    public init(storagePolicy: MBStoragePolicy = .InMemory, browserTools: [MBOperations] = []) {
        self.storagePolicy = storagePolicy
        self.browserTools = browserTools
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isParentNavigationBarHidden = self.navigationController?.isNavigationBarHidden ?? false
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        layoutConstraints()
        addTarget()
        addKeyboardObserver()
        setupView()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// Checking for file eviction
        MediaBrowserFileManager.shared.checkForEviction()
        /// Navigation Bar visibility
        self.navigationController?.isNavigationBarHidden = isParentNavigationBarHidden
        removeKeyboardObservers()
    }
    
    /// Basic UI setups
    private func setupView() {
        /// Default ViewController Implementation
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        /// View Layout Correction
        view.layoutIfNeeded()
        
        self.toggleBrowserOperationButtonVisibility(!browserTools.isEmpty)
    }
    
    func addViews() {
        self.view.backgroundColor = .black
        
        self.view.addSubview(contentStack)
        self.view.addSubview(bottomNavBar)
        contentStack.addArrangedSubViews([upperNavBar, pageViewControl])
        
        bottomNavBar.addSubview(collectionView)
        bottomNavBar.addSubview(descriptionTextField)
        bottomNavBar.addSubview(nextButton)
        
        upperNavBar.addSubview(dismissButton)
        upperNavBar.addSubview(browserTitleLabel)
        upperNavBar.addSubview(browserOptionsButton)
    }
    
    func layoutConstraints() {
        
        NSLayoutConstraint.activate([
            browserTitleLabel.topAnchor.constraint(equalTo: upperNavBar.topAnchor, constant: 16),
            browserTitleLabel.bottomAnchor.constraint(equalTo: upperNavBar.bottomAnchor, constant: -16),
            browserTitleLabel.leadingAnchor.constraint(equalTo: upperNavBar.leadingAnchor, constant: 48),
            browserTitleLabel.trailingAnchor.constraint(equalTo: upperNavBar.trailingAnchor, constant: -48)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: bottomNavBar.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: bottomNavBar.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: bottomNavBar.trailingAnchor, constant: 16),
            collectionView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            descriptionTextField.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            descriptionTextField.leadingAnchor.constraint(equalTo: bottomNavBar.leadingAnchor, constant: 16),
            descriptionTextField.bottomAnchor.constraint(equalTo: bottomNavBar.bottomAnchor, constant: -16),
            descriptionTextField.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            nextButton.centerYAnchor.constraint(equalTo: descriptionTextField.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: bottomNavBar.trailingAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.widthAnchor.constraint(equalToConstant: 44)
        ])
        
        nextButton.layer.cornerRadius = 22
        nextButton.layer.masksToBounds = true
        
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
            contentStack.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
        bottomConstraint = bottomNavBar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            bottomNavBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomNavBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bottomConstraint!
        ])
    }
    
    private func addTarget() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        self.pageViewControl.addGestureRecognizer(tapGesture)
        
        dismissButton.addTarget(self, action: #selector(didTapOnDismissButton), for: .touchUpInside)
        
        if #available(iOS 14.0, *) {
            browserOptionsButton.showsMenuAsPrimaryAction = true
            didTapOnBrowserOptionButton(sender: browserOptionsButton)
        }
        
    }
    
    /// View tap Action
    @objc private func didTapOnView() {
        toggleNavBarWithAnimation()
    }
    
    @available(iOS 14.0, *)
    @objc func didTapOnBrowserOptionButton(sender: UIButton) {
        
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
        
        let annotationAction = UIAction(title: MBOperations.Annotations.rawValue) { action in
            
            DispatchQueue.main.async { [weak self] in
                guard let self, let browsable = self.media[safeIndex: self.selectedIndex] else { return }
                self.delegate?.didTapAnnotations(browser: browsable)
            }
        }
        
        var menuChildren: [UIAction] = []
        
        browserTools.forEach { tool in
            
            switch tool {
            case .Share:
                menuChildren.append(shareAction)
                break
            case .Annotations:
                if shouldShowAnnotations() {
                    menuChildren.append(annotationAction)
                }
                break
            default: break
            }
        }
        
        let menu = UIMenu(title: "", children: menuChildren)
        self.browserOptionsButton.menu = menu
    }
    
    private func shouldShowAnnotations() -> Bool {
        guard let mediaType = toBrowseMediaTypes[safeIndex: selectedIndex]?.mediaType else { return true }
        switch mediaType {
        case .Image(_), .Photo(_):
            return true
        default:
            return false
        }
    }
    
    @objc func didTapOnDismissButton() {
        self.delegate?.willDismissMediaBrowserAtPageIndex(withIndex: selectedIndex, browser: self)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        media[selectedIndex].metaData = textField.text
    }
    
    @objc private func nextButtonTapped() {
        self.delegate?.didFinishBrowsingMedia(browsers: media)
    }
    
    func handleLoader(withStatus status: MBUploadStatus) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            switch status {
            case .Inprogress:
                self.loader.startLoading(withTitle: "Loading....")
                break
            case .Failed:
                self.loader.stopLoading()
                break
            case .Completed:
                self.loader.stopLoading()
                break
            }
        }
    }
    
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers(){
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Set Browser selection index
    func storeInSessionBrowser(index: Int, shouldReloadPager: Bool = false) {
        
        selectedIndex = index
        
        if shouldReloadPager {
            self.pageViewControl.set(selectedTabIndex: selectedIndex)
        }
        
        self.updateBrowserTitle(index: selectedIndex)
        
        /// Logging Current InSession Browser
        guard let currentBrowser = toBrowseMediaTypes[safeIndex: selectedIndex] else { return }
        self.inSessionBrowser = currentBrowser
        
        self.delegate?.mediaBrowserDidSwipe(withIndex: selectedIndex, browser: self)
    }
    
    public func getSelectedIndex() -> Int {
        return selectedIndex
    }
    
    public func reloadPager() {
        self.pageViewControl.reloadView(withSelectedIndex: selectedIndex)
    }
    
    func removeMedia(atIndex index: Int) {
        media.remove(at: index)
    }
}

extension MediaBrowser: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get current text
        let currentText = textField.text ?? ""
        
        // Create updated text after change
        guard let textRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        // Limit to 200 characters
        return updatedText.count <= 200
    }
}

// MARK: - Utility Methods
@available(iOS 13.0, *)
extension MediaBrowser {
    
    /// Medias to be rendered by the Browser
    /// - Parameters:
    ///   - media: Media(MediaBrowsable) to be rendered
    ///   - index: Index from which browsing needs to begin
    public func render(media: [MediaBrowsable], withSelectedIndex index: Int = 0) {
        self.media = media
        let preSelectedIndex = (index < media.count) ? index : 0
        self.selectedIndex = preSelectedIndex
        self.pageViewControl.defaultSelectedTab = preSelectedIndex
        self.descriptionTextField.text = media[preSelectedIndex].metaData
        self.storeInSessionBrowser(index: preSelectedIndex, shouldReloadPager: false)
    }
    
    /// Setting default image for all browsers
    /// - Parameter placeHolderImage: Place holder UIImage for the browser
    public func set(placeHolderImage: UIImage) {
        self.placeHolderImage = placeHolderImage
    }
}

// MARK: - Operations
@available(iOS 13.0, *)
extension MediaBrowser {
    
    /// Toggle Nav bar animation
    private func toggleNavBarWithAnimation() {
        
        guard !isKeyboardVisible else { return }
        
        bottomNavBar.alpha = isToolBarVisible ? 1 : 0
        upperNavBar.alpha = isToolBarVisible ? 1 : 0
        isToolBarVisible.toggle() /// On Tap toggle the bool
        
        if bottomNavBar.alpha == 1.0 {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.bottomNavBar.alpha = 0.0
                self?.upperNavBar.alpha = 0.0
                
            }) { (_) in }
        } else {
            bottomNavBar.isHidden = false
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.bottomNavBar.alpha = 1.0
                self?.upperNavBar.alpha = 1.0
            }
        }
        
        self.delegate?.mediaBrowserControlVisibilityToggled(browser: self, hidden: isToolBarVisible)
    }
    
    /// Show Share Sheet
    func showShareSheet(withItems items: [Any]) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            // On iPad, you need to specify a source view or bar button item for the popover to anchor to
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    /// UpdateBrowserTitle
    private func updateBrowserTitle(index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.browserTitleLabel.text = "\(index + 1)/\(toBrowseMediaTypes.count)"
        }
    }
    
    /// Toggle Browser Operations Visibility
    private func toggleBrowserOperationButtonVisibility(_ state: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.browserOptionsButton.isHidden = !state
        }
    }
    
    /// Toggle Browser title Visibility
    private func toggleBrowserTitleVisibility(_ state: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.browserTitleLabel.isHidden = !state
        }
    }
    
    /// Reload collection view
    private func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
        }
    }
    
    /// Alert View
    func showAlert(title: String, message: String) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
    
}

// MARK: - Storage base operations
@available(iOS 13.0, *)
extension MediaBrowser {
    
    /// Computing raw media data to MediaBrowsable format
    private func computeBrowsableData() {
        
        if !media.isEmpty {
            
            self.toBrowseMediaTypes = getMediaBrowserData()
            
            hideErrorSheet()
            
            /// After Initial boot, first browser needs to be explicitly set
            guard let currentBrowser = toBrowseMediaTypes[safeIndex: selectedIndex] else { return }
            self.inSessionBrowser = currentBrowser
            
        } else {
            
            handleError(content: .init(errorContent: .init(title: "No Images found", image: "error_504"), properties: .init(appSection: className)))
        }
        
        
        self.toggleBrowserTitleVisibility(!media.isEmpty)
        self.toggleBrowserOperationButtonVisibility(!browserTools.isEmpty && !media.isEmpty)
        self.reloadCollectionView()
    }
    
    private func getMediaBrowserData() -> [MediaBrowserData] {
        
        return media.compactMap({ MediaBrowserData(mediaType: $0.transformToBrowsableMedia(), placeHolder: $0.placeHolderImage) })
        
    }
    
    /// Checks for Storage policy and stores the media as per policy
    private func checkForStoragePolicyAndStoreMedia(cachedData: MBCacheable) {
        
        switch storagePolicy {
        case .InMemory:
            /*
             Already did, this is mandatory for every type of storage since for an active session of MediaManager,
             InMemory cache is used rather than fetching it from NSCache/Disk
             */
            break
        case .UsingNSCache:
            MediaBrowserCacheManager.shared.store(media: cachedData)
            break
        case .DiskStorage:
            MediaBrowserFileManager.shared.store(witheData: cachedData)
            break
        }
        
    }
}

// MARK: - UXPagerViewDelegate
@available(iOS 13.0, *)
extension MediaBrowser: UXPagerViewDelegate {
    
    public func pagerView(_ view: UXPagerView, tabTitleAtIndex index: Int) -> String {
        return ""
    }
    
    public func pagerView(_ view: UXPagerView, pageAtIndex index: Int) -> UIViewController? {
        
        guard let _toBrowseMediaType = toBrowseMediaTypes[safeIndex: index], let type = _toBrowseMediaType.mediaType else { return UIViewController() }
        
        /// If no image is set explicitly use the default image set via MediaBrowser, even when this is empty the MBConstant Images are used
        let _placeHolderImage = _toBrowseMediaType.placeHolder ?? placeHolderImage
        
        switch type {
        case .Image(let image):
            let viewController = MBPhotoBrowserViewController(image: image, placeHolder: _placeHolderImage, localMediaCache: _toBrowseMediaType.cachedData, storagePolicy: storagePolicy)
            viewController.browserIndex = index
            viewController.delegate = self
            return viewController
            
        case .Photo(let url):
            let viewController = MBPhotoBrowserViewController(url: url, placeHolder: _placeHolderImage, localMediaCache: _toBrowseMediaType.cachedData, storagePolicy: storagePolicy)
            viewController.browserIndex = index
            viewController.delegate = self
            return viewController
            
        case .Video(let url):
            let viewController = MBVideoBrowserViewController(url: url, placeHolder: _placeHolderImage, localMediaCache: _toBrowseMediaType.cachedData, storagePolicy: storagePolicy)
            viewController.browserIndex = index
            viewController.delegate = self
            return viewController
            
        case .Documents(let url):
            let viewController = MBDocumentBrowserViewController(url: url, placeHolder: _placeHolderImage, localMediaCache: _toBrowseMediaType.cachedData, storagePolicy: storagePolicy)
            viewController.browserIndex = index
            viewController.delegate = self
            return viewController
            
        case .Web(let url):
            let viewController = MBWebBrowserViewController(url: url, placeHolder: _placeHolderImage, localMediaCache: _toBrowseMediaType.cachedData, storagePolicy: storagePolicy)
            viewController.browserIndex = index
            viewController.delegate = self
            return viewController
        }
    }
    
    public func numberOfPages(_ view: UXPagerView) -> Int {
        return toBrowseMediaTypes.count
    }
    
    public func pagerView(_ view: UXPagerView, didSwipeTabTo index: Int) {
        self.collectionView(self.collectionView, didSelectItemAt: IndexPath(row: index, section: 0))
    }
}

// MARK: - MediaBrowserBaseViewDelegate
@available(iOS 13.0, *)
extension MediaBrowser: MediaBrowserBaseViewDelegate {
    
    func didFinishRenderingMedia(withIndexPath index: Int, cachedData: MBCacheable?, isCachingRequired: Bool) {
        
        guard let renderingFinishedBrowserId = toBrowseMediaTypes[safeIndex: index]?.id,
              let index = toBrowseMediaTypes.firstIndex(where: { $0.id == renderingFinishedBrowserId }) else { return }
        
        /*When a browser data is cached and the same browser is currently in session, then replace the empty cache with cached data*/
        if selectedIndex == index {
            inSessionBrowser?.set(cachedData: cachedData)
        }
        
        if let cachedData, isCachingRequired {
            /// In memory caching,
            /// Necessary since, we use this cached data locally while initialising new browsers in an active session
            toBrowseMediaTypes[index].set(cachedData: cachedData)
            /// Checking for other policy based caching
            checkForStoragePolicyAndStoreMedia(cachedData: cachedData)
            
        }
    }
    
    func didFailRenderingMedia(withIndexPath index: Int, error: MediaManagerError) {
        
    }
}

extension MediaBrowser {
    
    @objc func keyboardWillShow(notification: Notification){
        UIView.setAnimationsEnabled(true)
        
        if let newFrame = (notification.userInfo?[ UIResponder.keyboardFrameEndUserInfoKey ] as? NSValue)?.cgRectValue {
            let keyBoardRect =  newFrame
            let keyBoardHeight = keyBoardRect.height
            bottomConstraint?.constant = -keyBoardHeight+48
            isKeyboardVisible = true

            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.view.layoutIfNeeded()
                self.pageViewControl.set(selectedTabIndex: self.selectedIndex)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification){
        UIView.setAnimationsEnabled(true)
        bottomConstraint?.constant = 0
        isKeyboardVisible = false
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
            self.pageViewControl.set(selectedTabIndex: self.selectedIndex)
        }
    }
}

extension MediaBrowser : UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaDisplayCollectionViewCell.id, for: indexPath) as? MediaDisplayCollectionViewCell, let browsable = media[safeIndex: indexPath.row] else {
            return UICollectionViewCell()
        }
        cell.configure(withBrowsable: browsable)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard var selectedMedia = media[safeIndex: indexPath.row], !selectedMedia.isSelected else {
            self.delegate?.didDeleteMedia(browser: self, index: indexPath.row)
            return
        }
        
        var updatedMedia = media
        
        if selectedIndex >= 0 && selectedIndex < updatedMedia.count {
            updatedMedia[selectedIndex].isSelected = false
        }

        selectedMedia.isSelected = true
        updatedMedia[indexPath.row] = selectedMedia
        
        media = updatedMedia

        descriptionTextField.text = selectedMedia.metaData
        self.storeInSessionBrowser(index: indexPath.row, shouldReloadPager: true)
    }
}

// MARK: - ErrorViewRepresentable
@available(iOS 13.0, *)
extension MediaBrowser: ErrorViewRepresentable {
    
    var errorView: MBErrorView {
        return _errorView
    }
    
    var parentView: UIView {
        return self.pageViewControl
    }
}
