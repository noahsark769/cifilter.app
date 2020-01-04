//
//  ImageWorkshopConsoleMessageView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/3/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

/// View which displays information to the user in the filter workshop view, for example when a long-running image generation has completed,
/// or when generation of an image fails.
final class ImageWorkshopConsoleMessageView: UIView {
    enum MessageType {
        case success
        case error
    }

    private let label: UILabel = {
        let view = UILabel()
        view.font = UIFont.boldSystemFont(ofSize: 15)
        view.textColor = .white
        view.numberOfLines = 0
        return view
    }()

    init(type: MessageType, message: String) {
        super.init(frame: .zero)
        switch type {
        case .success:
            self.backgroundColor = Colors.successGreen.color
        case .error:
            self.backgroundColor = Colors.availabilityRed.color
        }

        addSubview(label)
        label.edges(to: self, insets: .all(10))
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.text = message

        // TODO: This is a very ugly hack
        label.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 0.90).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
