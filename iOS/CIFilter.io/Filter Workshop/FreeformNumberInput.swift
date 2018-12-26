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

    lazy var textView: UITextView = {
        let view = UITextView()
        view.layer.borderColor = UIColor(rgb: 0xeeeeee).cgColor
        view.layer.borderWidth = 1 / UIScreen.main.scale
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.font = UIFont(name: "Courier New", size: 17)
        view.textColor = .black
        view.backgroundColor = UIColor(rgb: 0xefefef)
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
}

extension FreeformNumberInput: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let number = FreeformNumberInput.numberFormatter.number(from: textView.text) else {
            print("WARNING FreeformNumberInput did not have valid number!")
            return
        }
        valueDidChangeObservable.onNext(number)
    }
}
