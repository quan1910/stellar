//
//  CardView.swift
//  Stellar
//
//  Created by Nguyen Minh Quan on 11/14/20.
//

import Foundation
import Reusable
import UIKit
import RxCocoa
import RxSwift
import Kingfisher

enum CardStatus {
    case like
    case nah
}

enum InfoType {
    case name
    case birthDate
    case location
    case phone
    case password
}

final class CardView: UIView, NibOwnerLoadable {
    
    private let padding: CGFloat = 20
    private var isHidingStatusLabel = false
    private var model: Person?
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var seperatorLine: UIImageView!
    @IBOutlet private weak var infoTitleLabel: UILabel!
    @IBOutlet private weak var infoValueLabel: UILabel!
    @IBOutlet private weak var likeLabel: CardStatusLabel!
    @IBOutlet private weak var nahLabel: CardStatusLabel!
    @IBOutlet private weak var infoStackView: UIStackView!
    
    var currentStatus: CardStatus?
    
    var personModel: Person? {
        get {
            return model
        }
    }
    
    private let buttonTypes: [InfoType] = [.name, .birthDate, .location, .phone, .password]
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    func configureModel(_ model: Person) {
        self.model = model
        showInfoType(.name)
        
        guard let urlString = model.picture?.large, let url = URL(string: urlString) else {
            return
        }
        self.avatarImageView.kf.setImage(with: url, completionHandler: { result in
            switch result {
            case .success:
                break
            case .failure:
                break
            }
        })
    }
    
    private func configureView() {
        loadNibContent()
        
        layer.borderWidth = 1
        backgroundColor = Colors.cardBackground
        dropCardShadow()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height/2
        avatarImageView.layer.masksToBounds = true
        
        avatarImageView.layer.borderWidth = 3
        avatarImageView.layer.borderColor = UIColor.gray.cgColor
        
        seperatorLine.backgroundColor = .gray

        likeLabel.status = .like
        nahLabel.status = .nah
        likeLabel.isHidden = true
        nahLabel.isHidden = true
        
        for type in buttonTypes {
            let button = CardInfoButton()
            button.infoType = type
            if type == .name {
                button.setState(.selected)
            }
            button.didTap = { [weak self] infoType in
                guard let self = self else { return }
                self.showInfoType(infoType)
                
                for view in self.infoStackView.arrangedSubviews {
                    
                    guard let infoButton = (view as? CardInfoButton) else { continue }
                    if infoButton.infoType != infoType {
                        infoButton.resetState()
                    }
                }
            }
            infoStackView.addArrangedSubview(button)
        }
    }

    func showCardStatus(_ status: CardStatus) {
        currentStatus = status
        switch status {
        case .like:
            showLikeStatus()
        case .nah:
            showNahStatus()
        }
    }
    
    private func showLikeStatus() {
        likeLabel.text = "Oh yes please"
        
        // fade out nahLabel
        if !nahLabel.isHidden {
            UIView.animate(withDuration: 0.15, animations: {
                self.nahLabel.alpha = 0
            }, completion: { (_) in
                self.nahLabel.isHidden = true
            })
        }
        
        // fade in likeLabel
        if likeLabel.isHidden {
            likeLabel.alpha = 0
            likeLabel.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.likeLabel.alpha = 1
            })
        }
    }
    
    private func showNahStatus() {
        nahLabel.text = "Just Nah"
        
        // fade out likeLabel
        if !likeLabel.isHidden {
            UIView.animate(withDuration: 0.15, animations: {
                self.likeLabel.alpha = 0
            }, completion: { (_) in
                self.likeLabel.isHidden = true
            })
        }
        
        // fade in nahLabel
        if nahLabel.isHidden {
            nahLabel.alpha = 0
            nahLabel.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.nahLabel.alpha = 1
            })
        }
    }
    
    func hideStatusLabel() {
        // fade out likeLabel
        if !likeLabel.isHidden {
            if isHidingStatusLabel { return }
            isHidingStatusLabel = true
            UIView.animate(withDuration: 0.15, animations: {
                self.likeLabel.alpha = 0
            }, completion: { (_) in
                self.likeLabel.isHidden = true
                self.isHidingStatusLabel = false
            })
        }
        // fade out nahLabel
        if !nahLabel.isHidden {
            if isHidingStatusLabel { return }
            isHidingStatusLabel = true
            UIView.animate(withDuration: 0.15, animations: {
                self.nahLabel.alpha = 0
            }, completion: { (_) in
                self.nahLabel.isHidden = true
                self.isHidingStatusLabel = false
            })
        }
        
        currentStatus = nil
    }
    
    private func showInfoType(_ type: InfoType) {
        switch type {
        case .name:
            infoTitleLabel.text = "My name is:"
            infoValueLabel.text = model?.fullName
        case .birthDate:
            infoTitleLabel.text = "My birth day is:"
            infoValueLabel.text = model?.birthDate
        case .location:
            infoTitleLabel.text = "My location is:"
            infoValueLabel.text = model?.fullAddress
        case .phone:
            infoTitleLabel.text = "My phone number is:"
            infoValueLabel.text = model?.cellPhone
        case .password:
            infoTitleLabel.text = "My password is:"
//            infoValueLabel.text = model?.id?.description
        }
    }
}

final class CardStatusLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.height / 2
        self.layer.masksToBounds = true
        self.font = UIFont.boldSystemFont(ofSize: 24)
        self.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }

    var status: CardStatus = .like {
        didSet {
            configureCardStatus(status)
        }
    }
    
    private func configureCardStatus(_ status: CardStatus) {
        switch status {
        case .like:
            textColor = .green
        case .nah:
            textColor = .red
        }
    }
}

final class CardInfoButton: UIButton {
    
    enum State {
        case selected
        case notSelected
    }
    
    private let disposeBag = DisposeBag()
    
    var infoType: InfoType = .name {
        didSet {
            configureInfoType(infoType)
        }
    }
    
    /// The Value is closure trigger when button did tap
    var didTap: ((InfoType) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        setState(.notSelected)
        rx.tap.subscribeNext({ [weak self] _ in
            guard let self = self else { return }
            self.didTap?(self.infoType)
            self.setState(.selected)
        }).disposed(by: disposeBag)
        
        setTitle(nil, for: .normal)
        imageView?.contentMode = .scaleAspectFit
    }
    
    func resetState() {
        setState(.notSelected)
    }
    
    func setState(_ state: State) {
        tintColor = (state == .selected) ? .systemGreen : .systemGray
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    private func configureInfoType(_ type: InfoType) {
        
        var image: UIImage?
        switch type {
        case .name:
            image = UIImage(named: "user")
        case .birthDate:
            image = UIImage(named: "cake")
        case .location:
            image = UIImage(named: "location")
        case .phone:
            image = UIImage(named: "phone")
        case .password:
            image = UIImage(named: "password")
        }
        
        setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        
    }
}
