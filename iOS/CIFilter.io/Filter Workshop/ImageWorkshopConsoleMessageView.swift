//
//  ImageWorkshopConsoleMessageView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/3/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

final class ImageWorkshopConsoleMessageView: UIView {
    enum MessageType {
        case success
        case error
    }

    private let label: UILabel = {
        let view = UILabel()
        view.font = UIFont.boldSystemFont(ofSize: 15)
        view.textColor = .white
        view.numberOfLines = 1
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
        label.text = message
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
