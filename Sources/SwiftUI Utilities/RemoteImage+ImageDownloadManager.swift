//
//  RemoteImage+ImageDownloadManager.swift
//  SwiftUI MVVM
//
//  Created by Yilei He on 3/12/19.
//  Copyright © 2019 Yilei He. All rights reserved.
//

import UIKit
import SwiftUIRemoteImage

extension ImageDownloadManager: RemoteImageLoader {
    public func loadImage(url: URL?, completionHandler: @escaping (PlatformImage?, [RemoteImageUserInfoKey : Any]?) -> Void) {
        guard let url = url else {
            return
        }
        retrieveImage(url: url) { (image, _) in
            completionHandler(image, nil)
        }
    }

    public func cancelLoadingImage(url: URL) {
        cancelRetrievingImage(url: url)
    }
}

extension RemoteImage {
    init(url: URL?, content: @escaping (UIImage?) -> Content) {
        self.init(url: url, remoteImageLoader: ImageDownloadManager.shared, content: content)
    }
}
