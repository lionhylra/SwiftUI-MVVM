//
//  UIApplication+endEditing.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 29/10/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import UIKit

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}
