//
//  View+Alert.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 12/11/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import SwiftUI

struct AlertItem<T: Hashable>: Identifiable {
    let id: T
}

extension View {
    func alert<Item: Hashable>(item: Binding<Item?>, content: (Item) -> Alert) -> some View {
        let newBinding = Binding(get: {
            item.wrappedValue.flatMap { AlertItem(id: $0) }
        }, set: { newValue in
            item.wrappedValue = newValue?.id
        })
        return alert(item: newBinding) { (item) -> Alert in
            content(item.id)
        }
    }
}
