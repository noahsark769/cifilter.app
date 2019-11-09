//
//  ColorHexInput.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 2/23/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit
import ColorCompatibility

final class ColorHexInput: UIControl, ControlValueReporting {
    fileprivate(set) var value: UIColor

    lazy var textView: UITextView = {
        let view = UITextView()
        view.layer.borderColor = ColorCompatibility.separator.cgColor
        view.layer.borderWidth = 1 / UIScreen.main.scale
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.font = UIFont.monospacedBodyFont()
        view.textColor = ColorCompatibility.label
        view.backgroundColor = ColorCompatibility.secondarySystemBackground
        view.keyboardType = .twitter // for the hashtag
        view.delegate = self
        return view
    }()

    init(default: UIColor?) {
        // TODO: default is unused
        self.value = .black
        super.init(frame: .zero)
        addSubview(textView)
        textView.heightAnchor <=> 36
        textView.edgesToSuperview()
    }

    func set(text: String) {
        guard self.shouldAllowTextUpdate(to: text) else {
            NonFatalManager.shared.log("ColorHexInputReceivedInvalidText", data: ["text": text])
            return
        }
        textView.text = text
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CharacterSet {
    static let hexCodeCharacters = CharacterSet(charactersIn: "#abcdefABCDEF1234567890")
}

extension ColorHexInput: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let color = UIColor(hexString: textView.text) {
            value = color
            self.sendActions(for: .valueChanged)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "" || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        let currentText: String = textView.text ?? ""
        guard let swiftRange = Range<String.Index>(range, in: currentText) else { return false }
        let effectiveText: String = currentText.replacingCharacters(in: swiftRange, with: text)
        return self.shouldAllowTextUpdate(to: effectiveText)
    }

    func shouldAllowTextUpdate(to effectiveText: String) -> Bool {
        // Allow deleting the entire text field
        if effectiveText.isEmpty {
            return true
        }

        let extraLength = effectiveText.contains("#") ? 1 : 0
        if effectiveText.count - extraLength > 8 {
            return false
        }

        // Return true if it looks like part of a hex code
        return CharacterSet.hexCodeCharacters.isSuperset(of: CharacterSet(charactersIn: effectiveText))
    }
}
