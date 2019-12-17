//
//  DetailsView.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 12/9/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import SwiftUI
import SwiftUIRemoteImage

struct DetailsView: View {
    var model: TVShowModel
    
    var body: some View {
        VStack {
            RemoteImage(url: model.image?.medium) { (image) in
                Image(uiImage: image ?? UIImage())
            }
            Text(model.summary ?? "").padding()
            Spacer()
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(model: TVShowModel.exampleListingData()[0])
    }
}
