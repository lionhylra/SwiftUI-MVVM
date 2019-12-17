//
//  LoadingIndicator.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 12/9/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import SwiftUI
import UIKit

struct ActivityIndicator: UIViewRepresentable {
    
    let style: UIActivityIndicatorView.Style
    var isAnimating: Bool
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ActivityIndicator(style: .medium, isAnimating: true)
                .padding()
                .previewLayout(.sizeThatFits)
            ActivityIndicator(style: .large, isAnimating: true)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
