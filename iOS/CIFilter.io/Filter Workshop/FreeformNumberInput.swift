//
//  FreeformNumberInput.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/26/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ColorCompatibility

final class FreeformNumberInput: UIView {
    private static var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        return formatter
    }()

    private let valueDidChangeObservable = PublishSubject<NSNumber>()
    lazy var valueDidChange: ControlEvent<NSNumber> = {
        return ControlEvent(events: valueDidChangeObservable)
    }()

    private(set) var lastValue: NSNumber? = nil

    private let allowsIntegerInputsOnly: Bool

    lazy var textView: UITextView = {
        let view = UITextView()
        view.layer.borderColor = ColorCompatibility.separator.cgColor
        view.layer.borderWidth = 1 / UIScreen.main.scale
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .medium)
        view.textColor = ColorCompatibility.label
        view.backgroundColor = ColorCompatibility.secondarySystemBackground
        view.keyboardType = self.allowsIntegerInputsOnly ? .numberPad : .decimalPad
        view.delegate = self
        return view
    }()

    // TODO: clean up this hacky duplication
    private init(minFloat: Float?, maxFloat: Float?, defaultValueFloat: Float?) {
        allowsIntegerInputsOnly = false
        super.init(frame: .zero)
        addSubview(textView)
        textView.heightAnchor <=> 36
        textView.edgesToSuperview()
    }

    convenience init(min: Float?, max: Float?, defaultValue: Float?) {
        self.init(minFloat: min, maxFloat: max, defaultValueFloat: defaultValue)
    }

    static func createEmptyFloat() -> FreeformNumberInput {
        return FreeformNumberInput(minFloat: nil, maxFloat: nil, defaultValueFloat: nil)
    }

    init(min: Int?, max: Int?, defaultValue: Int?) {
        allowsIntegerInputsOnly = true
        super.init(frame: .zero)
        addSubview(textView)
        textView.heightAnchor <=> 36
        textView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func publishValue(_ value: NSNumber) {
        lastValue = value
        valueDidChangeObservable.onNext(value)
    }
}

extension FreeformNumberInput: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let number = FreeformNumberInput.numberFormatter.number(from: textView.text) else {
            return
        }
        self.publishValue(number)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "" || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        let currentText: String = textView.text ?? ""
        guard let swiftRange = Range<String.Index>(range, in: currentText) else { return false }
        let effectiveText: String = currentText.replacingCharacters(in: swiftRange, with: text)

        // Allow deleting the entire text field
        if effectiveText.isEmpty {
            return true
        }

        // Allow inputting only a negative sign
        if effectiveText == "-" {
            return true
        }

        // If we only accept ints, disallow the decimal separator
        if allowsIntegerInputsOnly && effectiveText.contains(FreeformNumberInput.numberFormatter.decimalSeparator) {
            return false
        }

        return FreeformNumberInput.numberFormatter.number(from: effectiveText) != nil
    }
}

final class FreeformTextInput: UIView, UITextViewDelegate {
    private let valueDidChangeObservable = PublishSubject<String>()
    lazy var valueDidChange: ControlEvent<String> = {
        return ControlEvent(events: valueDidChangeObservable)
    }()

    lazy var textView: UITextView = {
        let view = UITextView()
        view.layer.borderColor = ColorCompatibility.separator.cgColor
        view.layer.borderWidth = 1 / UIScreen.main.scale
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .medium)
        view.textColor = ColorCompatibility.label
        view.backgroundColor = ColorCompatibility.secondarySystemBackground
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
        valueDidChangeObservable.onNext(value)
    }

    func textViewDidChange(_ textView: UITextView) {
        self.publishValue(textView.text ?? "")
    }
}
