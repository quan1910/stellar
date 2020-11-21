//
//  LoadingView.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/21/20.
//

import Reusable
import UIKit

final class LoadingView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var loadingLabel: UILabel!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    func configureView() {
        loadNibContent()
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }

    func play() {
        loadingLabel.text = "Đang tải ..."
        loadingIndicator.startAnimating()
    }

    func stop() {
        loadingIndicator.stopAnimating()
    }
    
    var isAnimating: Bool {
        return loadingIndicator.isAnimating
    }
}
