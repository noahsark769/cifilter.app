//
//  ImageChooserView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/23/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let artboardSize: CGFloat = 650
private let artboardPadding: CGFloat = 20
private let artboardSpacing: CGFloat = 20

private let builtInImageNames = [
    "knighted",
    "liberty"
]

final class ImageChooserView: UIView {
    private let chooseImageSubject = PublishSubject<UIImage>()
    lazy var didChooseImage = {
        ControlEvent<UIImage>(events: chooseImageSubject)
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .clear
        view.register(ImageChooserCell.self, forCellWithReuseIdentifier: String(describing: ImageChooserCell.self))
        view.isScrollEnabled = false

        guard let layout = view.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("Should be the right layout type")
        }
        layout.minimumInteritemSpacing = artboardSpacing
        layout.sectionInset = UIEdgeInsets(all: artboardPadding)
        view.collectionViewLayout = layout

        return view
    }()

    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(rgb: 0xeeeeee)
        self.disableTranslatesAutoresizingMaskIntoConstraints()
        self.widthAnchor <=> artboardSize
        self.heightAnchor <=> artboardSize

        self.addSubview(collectionView)
        collectionView.edgesToSuperview()

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageChooserView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let image = UIImage(named: builtInImageNames[indexPath.row])!
        self.chooseImageSubject.onNext(image)
    }
}

extension ImageChooserView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageChooserCell", for: indexPath) as! ImageChooserCell
        cell.set(image: UIImage(named: builtInImageNames[indexPath.row])!)
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return builtInImageNames.count
    }
}

extension ImageChooserView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (artboardSize - (artboardPadding * 2) - (artboardSpacing * 2)) / 3
        return CGSize(width: size, height: size)
    }
}
