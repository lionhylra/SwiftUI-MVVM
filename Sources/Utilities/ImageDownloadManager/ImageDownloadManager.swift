//
//  Copyright © 2018 Yilei He All rights reserved.
//

import UIKit

public final class ImageDownloadManager {
    public static let shared = ImageDownloadManager()
    private let downloader = URLBasedDownloadSession.default

    private init() {}

    /// 1. This method tries to retrieve image from memory cache first.
    /// 2. If image is not found, then it looks into ./Cache folder in the sandbox.
    /// 3. If image is not found, then it tries to download the image from the url.
    /// 4. While image is being downloaded, the progressHandler is called multiple times **on background thread**, until the image is downloaded.
    /// 5. After the image is downloaded, it calls the imageProcessor closure to process image. **Note, this closure is called on backgrond thread.** And then save the processed image to both file system cache and memory cache.
    /// 6. And the completion closure is called **on the main thread**.
    /// 7. Before retrieving image from memory cache, and before completion closure is called, the image will be decoded to bitmap first. Then it is rendered on screen faster.
    ///
    /// - Parameters:
    ///   - url: the url of image
    ///   - imageProcessor: a closure to process image. It is called on background thread.
    ///   - progressHandler: a closure is called on background thread to reflect the progress of downloading.
    ///   - completion: a closure is called on main thread after the downloading is finished.
    ///   - image: the image downloaded or nil.
    ///   - error: If the image is failed to be downloaded, the error will be included in this parameter. Otherwise, it is nil.
    public func retrieveImage(url: URL,
                              cacheManager: ImageCacheManager = .default,
                              imageProcessor: ((UIImage) -> UIImage)? = nil,
                              progressHandler: URLBasedDownloadSession.ProgressHandler? = nil,
                              completion:  ((_ image: UIImage?, _ error: Error?) -> Void)?) {

        cacheManager.image(forKey: url.absoluteString, completion: { (image) in
            if let image = image {
                completion?(image, nil)
            } else {
                self.downloadAndCacheImage(url: url, imageProcessor: imageProcessor, progressHandler: progressHandler, completion: completion)
            }
        })
    }

    private func downloadAndCacheImage(url: URL,
                                       cacheManager: ImageCacheManager = .default,
                                       imageProcessor: ((UIImage) -> UIImage)?,
                                       progressHandler: URLBasedDownloadSession.ProgressHandler?,
                                       completion:  ((_ image: UIImage?, _ error: Error?) -> Void)?) {

        URLBasedDownloadSession.default
            .startDownloadTask(url: url,
                               progressHandler: progressHandler,
                               completionHandler: { (tempLocation, error) in
                                if let tempLocation = tempLocation, let data = try? Data(contentsOf: tempLocation), let image = UIImage(data: data) {
                                    let processedImage = imageProcessor?(image) ?? image
                                    cacheManager.setImage(processedImage, forKey: url.absoluteString)

                                    DispatchQueue.main.async {
                                        if let decodedImage = ImageCacheManager.default.image(forKey: url.absoluteString) {
                                            completion?(decodedImage, nil)
                                        } else {
                                            completion?(processedImage, nil)
                                        }
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        completion?(nil, error)
                                    }
                                }
            })

    }

    public func cancelRetrievingImage(url: URL) {
        URLBasedDownloadSession.default.cancelDownloadTask(for: url)
    }

    public func prefetchImage(url: URL, cacheManager: ImageCacheManager = .default, imageProcessor: ((UIImage) -> UIImage)?) {
        retrieveImage(url: url, cacheManager: cacheManager, imageProcessor: imageProcessor, progressHandler: nil, completion: nil)
    }

    public func cancelCompletionHandlerForRetriving(url: URL, cacheManager: ImageCacheManager = .default, imageProcessor: ((UIImage) -> UIImage)?) {
        retrieveImage(url: url, cacheManager: cacheManager, imageProcessor: imageProcessor, progressHandler: nil, completion: nil)
    }
}
