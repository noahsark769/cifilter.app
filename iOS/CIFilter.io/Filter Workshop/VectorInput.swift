//
//  VectorInput.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/13/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit
import Combine

/**
 * A view that allows the user to input a CIVector.
 */
final class VectorInput: UIControl, ControlValueReporting {
    private(set) var value: CIVector? = nil
    private var cancellables = Set<AnyCancellable>()
    private var controlEventPublishers: [AnyPublisher<NSNumber?, Never>] = []

    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.alignment = .leading
        return view
    }()

    private let numberInputsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        return view
    }()

    private let buttonsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        return view
    }()

    private let removeButton: UIButton = {
        let view = UIButton()
        view.setTitle("Remove", for: .normal)
        view.setTitleColor(Colors.availabilityBlue.color, for: .normal)
        return view
    }()

    private let addButton: UIButton = {
        let view = UIButton()
        view.setTitle("Add", for: .normal)
        view.setTitleColor(Colors.availabilityBlue.color, for: .normal)
        return view
    }()

    init(defaultValue: CIVectorCodableWrapper?, initialComponents: Int) {
        // TODO: defaultValue is currently unused. We should put it in a BehaviorSubject
        super.init(frame: .zero)

        addSubview(mainStackView)
        mainStackView.edgesToSuperview()

        mainStackView.addArrangedSubview(numberInputsStackView)
        mainStackView.addArrangedSubview(buttonsStackView)

        buttonsStackView.addArrangedSubview(addButton)
        buttonsStackView.addArrangedSubview(removeButton)

        addButton.addTapHandler().sink { _ in
            self.addNumberInput()
        }.store(in: &self.cancellables)

        removeButton.addTapHandler().sink { _ in
            self.removeNumberInput()
        }.store(in: &self.cancellables)

        for _ in 0..<initialComponents {
            self.addNumberInput()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addNumberInput() {
        let input = FreeformNumberInput.createEmptyFloat()
        let publisher = input.addValueChangedObserver()
        publisher.sink { _ in
            self.publishVector()
        }.store(in: &self.cancellables)
        input.widthAnchor <=> 90
        numberInputsStackView.addArrangedSubview(input)
        controlEventPublishers.append(publisher)
    }

    private func removeNumberInput() {
        guard let lastArrangedSubview = numberInputsStackView.arrangedSubviews.last else {
            return
        }
        numberInputsStackView.removeArrangedSubview(lastArrangedSubview)
        lastArrangedSubview.removeFromSuperview()
        _ = self.controlEventPublishers.removeLast()
        self.publishVector()
    }

    private func publishVector() {
        var floats = [CGFloat]()
        for view in numberInputsStackView.arrangedSubviews {
            guard let input = view as? FreeformNumberInput else {
                continue
            }
            guard let value = input.value else {
                // If one of the inputs doesn't have a value, don't publish our vector
                return
            }
            floats.append(CGFloat(value.floatValue))
        }
        value = CIVector(floats: floats)
        self.sendActions(for: .valueChanged)
    }
}
