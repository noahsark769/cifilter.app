//
//  FilterWorkshopViewController.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/8/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FilterWorkshopViewController: UIViewController {
    private let bag = DisposeBag()
    private let applicator = AsyncFilterApplicator()
    private lazy var workshopView: FilterWorkshopView = {
        return FilterWorkshopView(applicator: self.applicator)
    }()
    private var currentImage: UIImage? = nil
    private let filter: FilterInfo
    private var shareItem: UIBarButtonItem! = nil
    private var inputImageCurrentlySelecting: String? = nil

    init(filter: FilterInfo) {
        self.filter = filter
        super.init(nibName: nil, bundle: nil)
        self.title = filter.name

        self.shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareButton))
        self.shareItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = shareItem

        applicator.events.observeOn(MainScheduler.instance).subscribe(onNext: { event in
            guard case let .generationCompleted(image, _) = event else {
                self.shareItem.isEnabled = false
                return
            }
            self.shareItem.isEnabled = true
            self.currentImage = image
        }).disposed(by: bag)

        workshopView.didChooseAddImage.subscribe(onNext: { paramName, sourceView in
            self.inputImageCurrentlySelecting = paramName
            let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            vc.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { _ in
                print("Take photo!")
            }))
            vc.addAction(UIAlertAction(title: "Select from library", style: .default, handler: { _ in
                print("LIBARY")
            }))
            vc.popoverPresentationController?.sourceView = sourceView
            vc.popoverPresentationController?.sourceRect = sourceView.bounds
            self.present(vc, animated: true, completion: nil)
        }).disposed(by: bag)
    }

    @objc private func didTapShareButton() {
        guard let image = currentImage else { return }
        let shareController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        shareController.modalPresentationStyle = .popover
        shareController.popoverPresentationController?.barButtonItem = self.shareItem
        self.present(shareController, animated: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = workshopView
        workshopView.set(filter: self.filter)
    }
}
