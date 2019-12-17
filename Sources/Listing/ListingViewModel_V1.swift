//
//  ListingViewModel.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 12/9/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import Foundation

final class ListingViewModel_V1: ObservableObject {

    @Published var errorString: String?

    @Published private(set) var models: [TVShowModel] = []

    @Published private(set) var isLoading: Bool = false

    var searchText: String = "" {
        didSet {
            debouncingManager.commit {
                self.search(keywords: self.searchText)
            }
        }
    }

    @Published var isSearchBarActive = false

    private let debouncingManager = DebouncingManager(delay: 0.3)

    init(models: [TVShowModel] = []) {
        self.models = models
    }

    enum Action {
        case onAppear
        case didTapReloadButton
        case executeSearchImmediately
    }

    func sendAction(_ action: Action) {
        switch action {
        case .onAppear:
            loadData()
        case .didTapReloadButton:
            loadData()
        case .executeSearchImmediately:
            debouncingManager.executeImmediately()
        }
    }

    private func loadData() {
        isLoading = true
        let url = URL(string: "http://api.tvmaze.com/shows")!
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            DispatchQueue.main.async {
                self.isLoading = false
                do {
                    if let data = data {
                        self.models = try JSONDecoder().decode([TVShowModel].self, from: data)
                    } else if let error = error {
                        self.errorString = error.localizedDescription
                    }
                } catch {
                    self.errorString = error.localizedDescription
                }
            }
        }.resume()
    }

    private func search(keywords: String) {
        if keywords.isEmpty {
            loadData()
            return
        }

        var url: URL = URL(string: "https://api.tvmaze.com/search/shows")!
        url.appendQueryItems([URLQueryItem(name: "q", value: keywords)])

        isLoading = true
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            let rawResult: Result<Data, Error>
            switch (data, error) {
            case let (d?, _):
                rawResult = .success(d)
            case let (_, e?):
                rawResult = .failure(e)
            default:
                rawResult = .failure(NSError(domain: "", code: 0, userInfo: nil))
                assertionFailure()
            }

            let result = rawResult.flatMap { data in
                return Result {
                    return try JSONDecoder().decode([SearchShowResultModel].self, from: data)
                }
            }

            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let searchResults):
                    self.models = searchResults.map { $0.show }
                case .failure(let error):
                    self.errorString = error.localizedDescription
                }
            }

        }.resume()
    }
}
