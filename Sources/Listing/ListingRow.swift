//
//  ListingRow.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 9/9/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import SwiftUI
import Combine
import SwiftUIRemoteImage

struct ListingRow: View {
    let title: String
    let genres: [String]
    let imageURL: URL?
    
    var body: some View {
        HStack(alignment: .top) {

            RemoteImage(url: imageURL) { image in
                Image(uiImage: image ?? UIImage())
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 160)
                    .border(Color(.systemGray5), width: 1)
                    .background(Color(.systemGray5))
                    .clipped()
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title)
                Text(genres.joined(separator: ", "))
            }
        }
        .padding(10)
    }
}

struct ListingRow_Previews: PreviewProvider {
    static var models: [TVShowModel] {
        return TVShowModel.exampleListingData()
    }
    
    static var previews: some View {
        List {
            ListingRow(title: models[0].name,
                       genres: models[0].genres,
                       imageURL: models[0].image?.medium)
        }
    }
}
