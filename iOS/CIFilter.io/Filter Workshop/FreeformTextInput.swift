//
//  FreeformTextInput.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/8/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import UIKit

final class FreeformTextInput: UIControl, UITextViewDelegate, ControlValueReporting {
    private(set) var value: String? = nil

    lazy var textView: UITextView = {
        let view = UITextView()
        view.layer.borderColor = UIColor.separator.cgColor
        view.layer.borderWidth = 1 / UIScreen.main.scale
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.font = UIFont.monospacedBodyFont()
        view.textColor = .label
        view.backgroundColor = .secondarySystemBackground
        view.delegate = self
        return view
    }()

    init() {
        super.init(frame: .zero)
        addSubview(textView)
        textView.heightAnchor <=> 36
        textView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func publishValue(_ value: String) {
        self.value = value
        self.sendActions(for: .valueChanged)
    }

    func textViewDidChange(_ textView: UITextView) {
        self.publishValue(textView.text ?? "")
    }
}
