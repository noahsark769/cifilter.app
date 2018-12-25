//
//  EitherView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/23/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class EitherView: UIView {
    private let firstView: UIView
    private let secondView: UIView
    init(_ firstView: UIView, _ secondView: UIView) {
        self.firstView = firstView
        self.secondView = secondView
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setEnabled(_ view: UIView) {
        if view == self.firstView {
            addSubview(self.firstView)
            self.firstView.edgesToSuperview()
            self.secondView.removeFromSuperview()
            self.firstView.edgesToSuperview()
        } else if view == self.secondView {
            addSubview(self.secondView)
            self.secondView.edgesToSuperview()
            self.firstView.removeFromSuperview()
            self.secondView.edgesToSuperview()
        } else {
            print("WARNING tried to set a view enabled that was not part of EitherView")
        }
        self.setNeedsUpdateConstraints()
    }
}
