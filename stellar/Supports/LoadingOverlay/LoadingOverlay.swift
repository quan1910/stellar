//
//  LoadingOverlay.swift
//  Stellar
//
//  Created by Nguyen Minh Quan on 11/21/20.
//

import SnapKit
import UIKit

final class LoadingOverlay: UIView {
    private static let sharedView: LoadingOverlay = {
        let frame: CGRect = UIApplication.shared.delegate?.window??.bounds ?? UIScreen.main.bounds
        let view = LoadingOverlay(frame: frame)
        return view
    }()

    private lazy var backgroundView = UIView()
    private lazy var loadingView = LoadingView()
    private var maxSupportedWindowLevel: UIWindow.Level = .alert + 2
    private(set) var isShowing = false
    private(set) var isEnabled = false
    public static func isVisible() -> Bool {
        return LoadingOverlay.sharedView.isShowing
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureLoadingView()
        backgroundView = createBackgroundView()
        layoutIfNeeded()
        alpha = 0
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createBackgroundView() -> UIView {
        let backgroundView = UIView(frame: bounds)
        backgroundView.backgroundColor = .init(white: 0, alpha: 0.4)
        insertSubview(backgroundView, belowSubview: loadingView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        return backgroundView
    }

    private func configureLoadingView() {
        addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(88)
        }
    }

    func show() {
        isShowing = true
        frontWindow?.addSubview(self)
        if !loadingView.isAnimating {
            loadingView.play()
        }
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState, animations: { [weak self] in
            self?.alpha = 1
        }, completion: nil)
    }

    func hide() {
        isShowing = false
        loadingView.stop()
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState, animations: { [weak self] in
            self?.alpha = 0
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            // make sure it's still hidden
            if !self.isShowing {
                self.removeFromSuperview()
            }
        })
    }

    private var frontWindow: UIWindow? {
        let frontToBackWindows = UIApplication.shared.windows.reversed()
        for window in frontToBackWindows {
            let windownOnMainScreen = window.screen == UIScreen.main
            let windowIsVisible = !window.isHidden && window.alpha > 0
            let windowLevelSupported = (window.windowLevel >= .normal && window.windowLevel <= maxSupportedWindowLevel)
            let windowKeyWindow = window.isKeyWindow
            if windownOnMainScreen, windowIsVisible, windowLevelSupported, windowKeyWindow {
                return window
            }
        }
        return nil
    }
}

extension LoadingOverlay {
    public static func setLoading(_ executing: Bool) {
        if executing != LoadingOverlay.isVisible() {
            if executing {
                LoadingOverlay.sharedView.show()
            } else {
                LoadingOverlay.sharedView.hide()
            }
        }
    }
}

