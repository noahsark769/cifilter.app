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
    private let applicator: AsyncFilterApplicator
    private var bag = DisposeBag()
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
    var didSaveOutputImage: PublishSubject<UIImage> {
        return outputImageView.didSaveImage
    }

    init(applicator: AsyncFilterApplicator) {
        self.applicator = applicator
        super.init(frame: .zero)
        self.backgroundColor = UIColor(patternImage: UIImage(named: "workshop-background")!)
        self.addSubview(stackView)

        // need to disable autoresizing mask for self since this view will be inside a scroll view,
        // and as such the superview will not be responsible for disabling its autoresizing mask
        [stackView, self].disableTranslatesAutoresizingMaskIntoConstraints()
        stackView.edges(to: self, insets: UIEdgeInsets(all: 100))

        outputImageView.enableSavingToPhotos = true

        applicator.events.observeOn(MainScheduler.instance).subscribe(onNext: { event in
            switch event {
            case .generationStarted:
                self.outputImageView.setLoading()
            case let .generationErrored(error):
                print("Generation errored! \(error)")
            case let .generationCompleted(image, _):
                print("Generation completed!!")
                self.outputImageView.set(image: image)
                print("Finished setting image")
            }
        }).disposed(by: bag)
    }

    func set(filter: FilterInfo) {
        self.filter = filter
        print(filter.parameters)
        parameterConfiguration = [:]
        stackView.removeAllArrangedSubviews()
        applicator.set(filter: filter)

        let imageParameters = filter.parameters.filter({ $0.classType == "CIImage" })
        let nonImageParameters = filter.parameters.filter({ $0.classType != "CIImage" })

        if nonImageParameters.count > 0 {
            stackView.addArrangedSubview(nonImageParametersView)
            nonImageParametersView.set(parameters: nonImageParameters)
            applicator.addSubscription(for: nonImageParametersView.didUpdateParameter.asObservable())
        }

        if imageParameters.count > 0 {
            stackView.addArrangedSubview(imageParametersView)
            imageParametersView.set(parameters: imageParameters)
            applicator.addSubscription(for: imageParametersView.didUpdateParameter.asObservable())
        }

        outputImageView.setDefault()
        stackView.addArrangedSubview(outputImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
