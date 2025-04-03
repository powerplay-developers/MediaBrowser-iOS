//
//  DescriptionView.swift
//  MediaBrowser
//
//  Created by Adarsh   on 15/03/25.
//

import UIKit

class DescriptionView: UIView {
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "DESCRIPTION"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    
    private let hideButton: UIButton = {
        let button = UIButton(type: .system)
        let hideImage = UIImage(named: "eye.open", in: Bundle.module, compatibleWith: nil)
        button.setImage(hideImage, for: .normal)
        button.setTitle(" View", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(toggleDescription), for: .touchUpInside)
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private var isDescriptionHidden = true {
        didSet {
            descriptionLabel.isHidden = isDescriptionHidden
            hideButton.setTitle(isDescriptionHidden ? " View" : " Hide", for: .normal)
            let image = isDescriptionHidden ? UIImage(named: "eye.open", in: Bundle.module, compatibleWith: nil) : UIImage(named: "eye.slash", in: Bundle.module, compatibleWith: nil)
            hideButton.setImage(image, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        layoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addViews()
        layoutConstraints()
    }
    
    private func addViews() {
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(hideButton)
        
        stackView.addArrangedSubview(headerStackView)
        stackView.addArrangedSubview(descriptionLabel)
        
        addSubview(stackView)
    }
    
    private func layoutConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            headerStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func setDescription(_ description: String) {
        self.descriptionLabel.text = description
    }
    
    @objc private func toggleDescription() {
        isDescriptionHidden = !isDescriptionHidden
        
        delegate?.descriptionViewDidTap(isDescriptionHidden)
        
        UIView.animate(withDuration: 0.3) {
            self.descriptionLabel.alpha = self.isDescriptionHidden ? 0 : 1
            self.stackView.layoutIfNeeded()
        }
    }
}
