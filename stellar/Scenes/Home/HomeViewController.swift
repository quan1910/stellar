//
//  HomeViewController.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/14/20.
//

import UIKit
import Action
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {

    private let candidateService: CandidateServiceType = AppEnvironment.current.candidateService
    private let localStorageService: LocalStorageServiceType = AppEnvironment.current.localStorageService
    
    private let disposeBag = DisposeBag()
    private var cards = [CardView]()
    
    lazy var homeViewModel: HomeViewModel = {
        let viewModel = HomeViewModel(candidateService: candidateService,
                                      localStorageService: localStorageService)
        return viewModel
    }()

    private var numberOfCardOnScreen: Int = 3
    private let scales: [CGFloat] = [1, 0.9, 0.8, 0.7, 0.6, 0.5]
    private let alphas: [CGFloat] = [1, 0.85, 0.6, 0.45, 0.3, 0.15]
    private let cardSpacing: CGFloat = 60
    private var isCardAnimating = false
    private let offsetRequired: CGFloat = 35
    private var dynamicAnimator: UIDynamicAnimator!
    private var panAttachmentBehavior: UIAttachmentBehavior!
    private var previousCardLocation: CGPoint?
    private var currentStatus: CardStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureView()
        configureFlow()
    }
    
    private func configureView() {
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        homeViewModel.fetchCandidates()
    }
    
    private func configureFlow() {
        homeViewModel.personDataStream
            .filter { !$0.isEmpty }
            .subscribeNext { [weak self] persons in
                self?.configureData(persons)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureData(_ persons: [Person]) {
        for person in persons {
            let card = CardView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 60, height: self.view.frame.height * 0.6))
            card.configureModel(person)
            cards.append(card)
        }
        
        layoutCards()
    }
    
    func layoutCards() {
        // Setup first car
        guard let firstCard = cards.first else { return }
        self.view.addSubview(firstCard)
        firstCard.layer.zPosition = CGFloat(cards.count)
        firstCard.center = self.view.center
        firstCard.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panHandler)))
        
        // Setup the remaining cards
        for i in 1...(numberOfCardOnScreen-1) {
            if i > (cards.count - 1) { continue }
            
            let card = cards[i]
            
            // Set card depth
            card.layer.zPosition = CGFloat(cards.count - i)
            let downscale = scales[i]
            let alpha = alphas[i]
            card.transform = CGAffineTransform(scaleX: downscale, y: downscale)
            card.alpha = alpha
            
           
            // Spacing card
            card.center.x = self.view.center.x
            card.frame.origin.y = firstCard.frame.origin.y + (CGFloat(i) * cardSpacing)
            
            self.view.addSubview(card)
        }
        
        self.view.bringSubviewToFront(firstCard)
    }
    
    func animateNextCard() {
        let duration: TimeInterval = 0.2
        for i in 1...(numberOfCardOnScreen-1) {
            if i > (cards.count - 1) { continue }
            let card = cards[i]
            let newDownscale = scales[i - 1]
            let newAlpha = alphas[i - 1]
            UIView.animate(withDuration: duration, delay: (TimeInterval(i - 1) * (duration / 2)), usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: [], animations: {
                card.transform = CGAffineTransform(scaleX: newDownscale, y: newDownscale)
                card.alpha = newAlpha
                
                card.center = self.view.center
                
                if i - 1 > 0 {
                    card.frame.origin.y = self.cards[i - 1].frame.origin.y + self.cardSpacing
                }
                
            }, completion: { (_) in
                // Add pan gensture to first next card
                if i == 1 {
                    card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panHandler)))
                }
            })
            
        }
        
        // No more card lefts
        if numberOfCardOnScreen > (cards.count - 1) {
            if cards.count != 1 {
                self.view.bringSubviewToFront(cards[1])
            }
            return
        }
        let newCard = cards[numberOfCardOnScreen]
        newCard.layer.zPosition = CGFloat(cards.count - numberOfCardOnScreen)
        let initialScale = scales[numberOfCardOnScreen-1]
        let initialAlpha = alphas[numberOfCardOnScreen-1]
        
        // New card setup
        newCard.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        newCard.alpha = 0
        newCard.center.x = self.cards[numberOfCardOnScreen-1].center.x
        newCard.frame.origin.y = cards[numberOfCardOnScreen-1].frame.origin.y + (cardSpacing)
        self.view.addSubview(newCard)
        
        // Animate insert new card
        UIView.animate(withDuration: duration, delay: 1.5 * duration, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            newCard.transform = CGAffineTransform(scaleX: initialScale, y: initialScale)
            newCard.alpha = initialAlpha
            newCard.frame.origin.y = self.cards[self.numberOfCardOnScreen-1].frame.origin.y + self.cardSpacing
        }, completion: { (_) in
            
        })
        
        self.view.bringSubviewToFront(self.cards[1])
    }
    
    func removeSwipedCard() {
        cards[0].removeFromSuperview()
        cards.remove(at: 0)
    }
    
    @objc func panHandler(sender: UIPanGestureRecognizer) {
        if isCardAnimating { return }
        guard let firstCard = cards.first else { return }
        
        let cardPanScreen = sender.location(in: view)
        let cardPanLocation = sender.location(in: firstCard)
        switch sender.state {
        case .began:
            previousCardLocation = firstCard.center
            
            dynamicAnimator.removeAllBehaviors()
            let offset = UIOffset(horizontal: cardPanLocation.x - firstCard.bounds.midX, vertical: cardPanLocation.y - firstCard.bounds.midY)
            
            panAttachmentBehavior = UIAttachmentBehavior(item: firstCard, offsetFromCenter: offset, attachedToAnchor: cardPanScreen)
            dynamicAnimator.addBehavior(panAttachmentBehavior)
        case .changed:
            panAttachmentBehavior.anchorPoint = cardPanScreen
            handleCardPanChanged(firstCard, sender: sender)
        case .ended:
            handleCardPanEnded(firstCard, sender: sender)
        default:
            break
        }
    }
    
    func discardFirstCard() {
        guard let firstCard = cards.first else {
            return
        }
        
        // Improve discard animation with an interval timer
        var cardOutOfScreenTimer: Timer? = nil
        self.isCardAnimating = true
        cardOutOfScreenTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            if !self.view.bounds.contains(firstCard.center) {
                cardOutOfScreenTimer?.invalidate()
                self.isCardAnimating = true
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                    firstCard.alpha = 0.0
                }, completion: { [weak self] (_) in
                    self?.removeSwipedCard()
                    self?.isCardAnimating = false
                })
            }
        })
    }
    
    /// Hide status bar
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    private func handleCardPanChanged(_ card: CardView, sender: UIPanGestureRecognizer) {
        if card.center.x > (self.view.center.x + offsetRequired) {
            card.showCardStatus(.like)
        } else if card.center.x < (self.view.center.x - offsetRequired) {
            card.showCardStatus(.nah)
        } else {
            card.hideStatusLabel()
        }
    }
    
    private func handleCardPanEnded(_ card: CardView, sender: UIPanGestureRecognizer) {
        dynamicAnimator.removeAllBehaviors()
        // Pan not out of the required offset -> snap back to previous location
        if !isCardShouldBeSwiped(card) {
            addSnapToCenterEffect(card)
        } else {
            checkDirectionLastSwipe(card, sender: sender)
            addPushEffect(card, sender: sender)
            addSpinningEffect(card)
            handleLogicCardStatus(card)
            animateNextCard()
            discardFirstCard()
        }
    }
    
    private func handleLogicCardStatus(_ card: CardView) {
        switch card.currentStatus {
        case .like:
            guard let model = card.personModel else { return }
            homeViewModel.addFavorite(model)
        case .nah:
            break
        default:
            break
        }
    }
    
    private func addSpinningEffect(_ card: CardView) {
        // Create spinning effect
        var expectedAngle = CGFloat.pi / 3
        let cardAngle: Double = atan2(Double(card.transform.b), Double(card.transform.a))
        
        expectedAngle = (cardAngle > 0) ? expectedAngle : (expectedAngle * -1)
        let spinEffect = UIDynamicItemBehavior(items: [card])
        spinEffect.friction = 0.1
        spinEffect.addAngularVelocity(CGFloat(expectedAngle), for: card)
        spinEffect.allowsRotation = true
        
        dynamicAnimator.addBehavior(spinEffect)
    }
    
    private func addPushEffect(_ card: CardView, sender: UIPanGestureRecognizer) {
        // Create push away feeling
        let touchInView = sender.translation(in: view)
        
        let pushEffect = UIPushBehavior(items: [card], mode: .instantaneous)
        pushEffect.magnitude = 130
        
        // Push at the released direction
        pushEffect.pushDirection = CGVector(dx: touchInView.x, dy: touchInView.y)
        dynamicAnimator.addBehavior(pushEffect)
    }
    
    private func addSnapToCenterEffect(_ card: CardView) {
        // Snap back center
        guard let cardLocation = previousCardLocation else { return }
        let snapBackPreviousLocation = UISnapBehavior(item: card, snapTo: cardLocation)
        dynamicAnimator.addBehavior(snapBackPreviousLocation)
    }
    
    private func checkDirectionLastSwipe(_ card: CardView, sender: UIPanGestureRecognizer) {
        if let direction = sender.direction {
            switch direction {
            case .left:
                card.showCardStatus(.nah)
            case .right:
                card.showCardStatus(.like)
            }
        }
    }
    
    private func isCardShouldBeSwiped(_ card: CardView) -> Bool {
        return card.center.x > (self.view.center.x + offsetRequired) || card.center.x < (self.view.center.x - offsetRequired)
    }
}
