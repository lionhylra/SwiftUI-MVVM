//
//  View+ForceUpdate.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 6/12/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import SwiftUI

public struct ForceUpdateHandler: Hashable {
    fileprivate var id: Bool = false
    mutating func forceUpdate() {
        id.toggle()
    }
}

extension View {
    public func forceUpdateHandler(_ handler: ForceUpdateHandler) -> some View {
        id(handler.id)
    }
}
