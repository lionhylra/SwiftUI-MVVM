//
//  ListingViewModel2.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 7/11/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import Foundation
import Combine

final class ListingViewModel_V2: ObservableObject {

    @Published var errorString: String?

    @Published private(set) var models: [TVShowModel] = []

    @Published private(set) var isLoading: Bool = false

    @Published var searchText: String = ""

    private let loadDataSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(models: [TVShowModel] = []) {
        self.models = models
        configureBindings()
    }

    private func configureBindings() {
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .setFailureType(to: Error.self)
            .handleEvents(receiveOutput: { [unowned self] (_) in
                self.isLoading = true
            })
            .flatMap { [unowned self] (keywords) -> AnyPublisher<[TVShowModel], Error> in
                if keywords.isEmpty {
                    return self.loadData()
                } else {
                    return self.searchMovies(keywords: keywords)
                }
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [unowned self] (_) in
                self.isLoading = false
            })
            .catch({ [unowned self] (error) -> Just<[TVShowModel]> in
                self.errorString = error.localizedDescription
                return Just([])
            })
            .assign(to: \.models, on: self)
            .store(in: &cancellables)

        loadDataSubject
            .setFailureType(to: Error.self)
            .handleEvents(receiveOutput: { [unowned self] (_) in
                self.isLoading = true
            })
            .flatMap { [unowned self] in
                self.loadData()
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [unowned self] (_) in
                self.isLoading = false
            })
            .catch({ [unowned self] (error) -> Just<[TVShowModel]> in
                self.errorString = error.localizedDescription
                return Just([])
            })
            .assign(to: \.models, on: self)
            .store(in: &cancellables)
    }

    enum Action {
        case onAppear
        case didTapReloadButton
        case executeSearchImmediately
    }

    func sendAction(_ action: Action) {
        switch action {
        case .onAppear, .didTapReloadButton:
            loadDataSubject.send()
        case .executeSearchImmediately:
            // TODO
            break
        }
    }

    private func searchMovies(keywords: String) -> AnyPublisher<[TVShowModel], Error> {
        var url = URL(string: "https://api.tvmaze.com/search/shows")!
        url.appendQueryItems([URLQueryItem(name: "q", value: keywords)])

        return URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { (data, response) in
                try JSONDecoder().decode([SearchShowResultModel].self, from: data).map { $0.show }
            }
            .eraseToAnyPublisher()
    }

    private func loadData() -> AnyPublisher<[TVShowModel], Error> {
        let url = URL(string: "http://api.tvmaze.com/shows")!
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { (data, response) in
                try JSONDecoder().decode([TVShowModel].self, from: data)
            }
            .eraseToAnyPublisher()
    }
}
