//
//  FilterWorkshopContentView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/14/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import AloeStackView

final class FilterWorkshopContentView: UIView {
    private var bag: DisposeBag? = nil
    private var filter: FilterInfo! = nil
    private let nonImageParametersView = FilterWorkshopParametersView()
    private let imageParametersView = FilterWorkshopParametersView()
    private lazy var outputImageView: ImageArtboardView = ImageArtboardView(name: "outputImage")

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 100
        view.alignment = .top
        return view
    }()

    private var parameterConfiguration: [String: Any] = [:]

    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(patternImage: UIImage(named: "workshop-background")!)
        self.addSubview(stackView)

        // need to disable autoresizing mask for self since this view will be inside a scroll view,
        // and as such the superview will not be responsible for disabling its autoresizing mask
        [stackView, self].disableTranslatesAutoresizingMaskIntoConstraints()
        stackView.edges(to: self, insets: UIEdgeInsets(all: 100))
    }

    func set(filter: FilterInfo) {
        self.filter = filter
        print(filter.parameters)
        bag = DisposeBag() // unsubscribe all current subscriptions
        parameterConfiguration = [:]
        stackView.removeAllArrangedSubviews()

        let imageParameters = filter.parameters.filter({ $0.classType == "CIImage" })
        let nonImageParameters = filter.parameters.filter({ $0.classType != "CIImage" })

        if nonImageParameters.count > 0 {
            stackView.addArrangedSubview(nonImageParametersView)
            nonImageParametersView.set(parameters: nonImageParameters)
            nonImageParametersView.didUpdateParameter.subscribe(onNext: { (name, value) in
                self.parameterConfiguration[name] = value
                self.generateOutputImageIfPossible()
            }).disposed(by: bag!)
        }

        if imageParameters.count > 0 {
            stackView.addArrangedSubview(imageParametersView)
            imageParametersView.set(parameters: imageParameters)
            imageParametersView.didUpdateParameter.subscribe(onNext: { (name, value) in
                self.parameterConfiguration[name] = value
                self.generateOutputImageIfPossible()
            }).disposed(by: bag!)
        }

        stackView.addArrangedSubview(outputImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func generateOutputImageIfPossible() {
        let filter = CIFilter(name: self.filter.name)!
        for parameter in self.filter.parameters {
            guard let value = parameterConfiguration[parameter.name] else {
                print("Not ready yet, need \(parameter.name)")
                return
            }
            filter.setValue(value, forKey: parameter.name)
        }
        let image = UIImage(ciImage: filter.outputImage!)
        outputImageView.set(image: image)
    }
}
