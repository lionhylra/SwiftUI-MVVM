//
//  SearchBar2.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 7/11/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import SwiftUI
import Combine

struct SearchBar2: View {

    @ObservedObject private var viewModel: ViewModel = ViewModel()

    init(binding: ((_ editingEvents: AnyPublisher<String, Never>, _ commitEvents: AnyPublisher<Void, Never>, _ cancelEvents: AnyPublisher<Void, Never>, _ isActiveEvents: AnyPublisher<Bool, Never>) -> Void)? = nil) {
        binding?(viewModel.editingEventsSubject.eraseToAnyPublisher(), viewModel.comitEventsSubject.eraseToAnyPublisher(), viewModel.cancelEventsSubject.eraseToAnyPublisher(), viewModel.isActiveEventsSubject.eraseToAnyPublisher())
    }

    var body: some View {
        HStack {
            HStack {
                magnifyingIcon
                searchField
                clearButton
            }
            .padding(8)
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            if viewModel.isActive || !viewModel.searchText.isEmpty {
                cancelButton
            }
        }
        .animation(.easeInOut)
    }

    private var cancelButton: some View {
        Button("Cancel") {
            UIApplication.shared.dismissKeyboard()
            self.viewModel.searchText = ""
            self.viewModel.isActive = false
            self.viewModel.cancelEventsSubject.send()
        }
        .foregroundColor(.accentColor)
    }

    private var magnifyingIcon: some View {
        Image(systemName: "magnifyingglass")
    }

    private var clearButton: some View {
        Button(action: {
            self.viewModel.searchText = ""
            self.viewModel.cancelEventsSubject.send()
        }) {
            Image(systemName: "xmark.circle.fill")
                .opacity(viewModel.searchText == "" ? 0 : 1)
        }
    }

    private var searchField: some View {
        TextField("Search", text: $viewModel.searchText, onEditingChanged: { isEditing in
            self.viewModel.isActive = isEditing
        }, onCommit: {
            UIApplication.shared.dismissKeyboard()
            self.viewModel.isActive = false
            self.viewModel.comitEventsSubject.send()
        })
            .foregroundColor(.primary)
    }

    private final class ViewModel: ObservableObject {
        var searchText: String = "" {
            didSet {
                editingEventsSubject.send(searchText)
            }
        }
        @Published var isActive: Bool = false {
            didSet {
                isActiveEventsSubject.send(isActive)
            }
        }
        var comitEventsSubject = PassthroughSubject<Void, Never>()
        var cancelEventsSubject = PassthroughSubject<Void, Never>()
        var editingEventsSubject = PassthroughSubject<String, Never>()
        var isActiveEventsSubject = PassthroughSubject<Bool, Never>()
    }
}

struct SearchBar2_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchBar2()
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Light Mode")

            SearchBar2()
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Dark Mode")
                .environment(\.colorScheme, .dark)

            SearchBar2()
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("With Cancel Button")
        }
    }
}

