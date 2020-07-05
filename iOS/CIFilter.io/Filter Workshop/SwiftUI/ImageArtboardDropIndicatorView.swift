//
//  ImageArtboardDropIndicatorView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/29/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import SwiftUI

struct ImageArtboardDropIndicatorView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "square.and.arrow.down.fill")
                Text("Drop image")
                Spacer()
            }
            Spacer()
        }.background(
            Color(.systemBackground).opacity(0.7)
        )
    }
}

struct ImageArtboardDropIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageArtboardDropIndicatorView().previewLayout(.fixed(width: 400, height: 300))
    }
}
