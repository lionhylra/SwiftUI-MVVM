//
//  ListingView.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 9/9/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import SwiftUI

typealias ListingViewModel = ListingViewModel_V2

struct ListingView: View {
    
    @ObservedObject var viewModel: ListingViewModel

    @State var isSearchBarActive: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                searchBar
                    .padding(.horizontal)

                List(viewModel.models) { (model) in
                    NavigationLink(destination: DetailsView(model: model)) {
                        self.row(model: model)
                    }
                }
                .navigationBarTitle("TV Shows")
                .navigationBarItems(trailing: reloadButton)
                .navigationBarHidden(isSearchBarActive)
            }
        }
        .overlay(activityIndicator)
        .onAppear {
//            self.viewModel.searchText = "Boy"
            self.viewModel.sendAction(.onAppear)
        }
        .alert(item: $viewModel.errorString, content: alert)
    }

    private var searchBar: some View {
        SearchBar(searchText: $viewModel.searchText, onCommit: {
            self.viewModel.sendAction(.executeSearchImmediately)
        }, onCancel: {
            self.viewModel.sendAction(.executeSearchImmediately)
        }, isActive: $isSearchBarActive)
    }

    private func row(model: TVShowModel) -> ListingRow {
        ListingRow(title: model.name,
                   genres: model.genres,
                   imageURL: model.image?.medium)
    }


    private func alert(errorString: String) -> Alert {
        Alert(
            title: Text("Error"),
            message: Text(errorString),
            dismissButton: .default(Text("Ok"))
        )
    }

    private var activityIndicator: some View {
        return ActivityIndicator(style: .large, isAnimating: viewModel.isLoading)
    }
    
    private var reloadButton: some View {
        Button("Reload") {
            self.viewModel.sendAction(.didTapReloadButton)
        }
    }
}

struct ListingView_Previews: PreviewProvider {
    static var previews: some View {
        ListingView(viewModel: ListingViewModel(models: TVShowModel.exampleListingData()))
    }
}
