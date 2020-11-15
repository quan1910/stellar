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
    
    private let disposeBag = DisposeBag()
    private var cards = [CardView]()
    
    lazy var homeViewModel: HomeViewModel = {
        let viewModel = HomeViewModel(candidateService: candidateService)
        return viewModel
    }()

    private var numberOfCardOnScreen: Int = 5
    private let scales: [CGFloat] = [1, 0.9, 0.8, 0.7, 0.6, 0.5]
    private let alphas: [CGFloat] = [1, 0.85, 0.6, 0.45, 0.3, 0.15]
    private let cardSpacing: CGFloat = 60
    private var isCardAnimating = false
    private let offsetRequired: CGFloat = 15
    private var dynamicAnimator: UIDynamicAnimator!
    private var panAttachmentBehavior: UIAttachmentBehavior!
    private var previousCardLocation: CGPoint?
    
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
            card.frame.origin.y = cards[0].frame.origin.y + (CGFloat(i) * cardSpacing)
            
            self.view.addSubview(card)
        }
        
        self.view.bringSubviewToFront(cards[0])
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
                if i == 1 {
                    card.center = self.view.center
                } else {
                    card.center.x = self.view.center.x
                    card.frame.origin.y = self.cards[1].frame.origin.y + (CGFloat(i - 1) * self.cardSpacing)
                }
                
            }, completion: { (_) in
                if i == 1 {
                    card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panHandler)))
                }
            })
            
        }
        
        // No more card lefts
        if 4 > (cards.count - 1) {
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
        
        let cardPanScreen = sender.location(in: view)
        let cardPanLocation = sender.location(in: cards[0])
        switch sender.state {
        case .began:
            previousCardLocation = cards[0].center
            
            dynamicAnimator.removeAllBehaviors()
            let offset = UIOffset(horizontal: cardPanLocation.x - cards[0].bounds.midX, vertical: cardPanLocation.y - cards[0].bounds.midY)
            
            panAttachmentBehavior = UIAttachmentBehavior(item: cards[0], offsetFromCenter: offset, attachedToAnchor: cardPanScreen)
            dynamicAnimator.addBehavior(panAttachmentBehavior)
        case .changed:
            panAttachmentBehavior.anchorPoint = cardPanScreen
            
            if cards[0].center.x > (self.view.center.x + offsetRequired) {
                cards[0].showCardStatus(.like)
            } else if cards[0].center.x < (self.view.center.x - offsetRequired) {
                cards[0].showCardStatus(.nah)
            } else {
                cards[0].hideStatusLabel()
            }
            
        case .ended:
            
            dynamicAnimator.removeAllBehaviors()
            
            // Pan not out of the required offset -> snap back to previous location
            if !(cards[0].center.x > (self.view.center.x + offsetRequired) || cards[0].center.x < (self.view.center.x - offsetRequired)) {
                // Snap back center
                guard let cardLocation = previousCardLocation else { return }
                let snapBackPreviousLocation = UISnapBehavior(item: cards[0], snapTo: cardLocation)
                dynamicAnimator.addBehavior(snapBackPreviousLocation)
            } else {
                
                // Create push away feeling
                let velocity = sender.velocity(in: self.view)
                let pushEffect = UIPushBehavior(items: [cards[0]], mode: .instantaneous)
                pushEffect.pushDirection = CGVector(dx: velocity.x/10, dy: velocity.y/10)
                pushEffect.magnitude = 125
                dynamicAnimator.addBehavior(pushEffect)
                
                // Create spinning effect
                var expectedAngle = CGFloat.pi / 2 // angular velocity of spin
                let cardAngle: Double = atan2(Double(cards[0].transform.b), Double(cards[0].transform.a))
                
                expectedAngle = (cardAngle > 0) ? expectedAngle : (expectedAngle * -1)
                let spinEffect = UIDynamicItemBehavior(items: [cards[0]])
                spinEffect.friction = 0.3
                spinEffect.allowsRotation = true
                spinEffect.addAngularVelocity(CGFloat(expectedAngle), for: cards[0])
                dynamicAnimator.addBehavior(spinEffect)
                
                animateNextCard()
                discardFirstCard()
            }
        default:
            break
        }
    }
    
    func discardFirstCard() {
        self.isCardAnimating = true
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [.curveEaseIn], animations: {
            self.cards[0].alpha = 0.0
        }, completion: { (_) in
            self.removeSwipedCard()
            self.isCardAnimating = false
        })
    }
    
    /// Hide status bar
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}
