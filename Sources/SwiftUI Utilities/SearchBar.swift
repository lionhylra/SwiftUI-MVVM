//
//  SearchBar.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 29/10/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import SwiftUI

struct SearchBar: View {

    @Binding private var searchText: String
    private let onCommit: (() -> Void)?
    private let onCancel: (() -> Void)?
    @Binding private var isActive: Bool

    init(searchText: Binding<String>,
         onCommit: (() -> Void)? = nil,
         onCancel: (() -> Void)? = nil,
         isActive: Binding<Bool>? = nil) {
        self._searchText = searchText
        self.onCommit = onCommit
        self.onCancel = onCancel
        if let isActive = isActive {
            self._isActive = isActive
        } else {
            var isActive = false
            self._isActive = Binding(get: {
                isActive
            }, set: { (newValue) in
                isActive = newValue
            })
        }
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
            if isActive || !searchText.isEmpty {
                cancelButton
            }
        }
        .animation(.easeInOut)
    }

    private var cancelButton: some View {
        Button("Cancel") {
            UIApplication.shared.dismissKeyboard()
            self.searchText = ""
            self.isActive = false
            self.onCancel?()
        }
        .foregroundColor(.accentColor)
    }

    private var magnifyingIcon: some View {
        Image(systemName: "magnifyingglass")
    }

    private var clearButton: some View {
        Button(action: {
            self.searchText = ""
            self.onCancel?()
        }) {
            Image(systemName: "xmark.circle.fill")
                .opacity(searchText == "" ? 0 : 1)
        }
    }

    private var searchField: some View {
        TextField("Search", text: $searchText, onEditingChanged: { isEditing in
            self.isActive = isEditing
        }, onCommit: {
            UIApplication.shared.dismissKeyboard()
            self.isActive = false
            self.onCommit?()
            })
            .foregroundColor(.primary)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchBar(searchText: Binding.constant(""))
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Light Mode")

            SearchBar(searchText: Binding.constant(""))
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Dark Mode")
                .environment(\.colorScheme, .dark)

            SearchBar(searchText: Binding.constant(""), isActive: .constant(true))
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("With Cancel Button")
        }
    }
}
