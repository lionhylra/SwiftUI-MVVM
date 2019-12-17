//
//  ImageCacheManager.swift
//  Swift3Project
//
//  Created by Yilei on 4/4/17.
//  Copyright © 2017 Yilei He All rights reserved.
//

import UIKit

public class ImageCacheManager: NSObject {

    /// The storage strategy of the cache manager
    ///
    /// - memory: only use memory cache, internally use NSCache
    /// - fileSystem: only use file system to store cache. If persistent is `true`, the folder will be stored in FileManager.SearchPathDirectory.documentDirectory, otherwise, in FileManager.SearchPathDirectory.cachesDirectory.
    /// - memoryAndFileSystem: use both memory cache and file system cache. If persistent is `true`, the folder will be stored in FileManager.SearchPathDirectory.documentDirectory, otherwise, in FileManager.SearchPathDirectory.cachesDirectory.
    public enum CacheType {
        case memory
        case fileSystem(persistent: Bool)
        case memoryAndFileSystem(persistent: Bool)
    }

    fileprivate let fileManager: FileSessionManager?

    fileprivate let memoryCache: NSCache<NSString, UIImage>?

    /// Initialize an instance using CacheManager(type: .memoryAndFileSystem(persistent:false)). This will store cached data to memory and <Sandbox>/Library/Caches/com.lionhylra.CacheManager/ folder.
    public static let `default` = try! ImageCacheManager(type: .memoryAndFileSystem(persistent: false))

    fileprivate let ioQueue = DispatchQueue(label: "\(Bundle(for: ImageCacheManager.self).bundleIdentifier!).\(String(describing: ImageCacheManager.self)).ioQueue")

    /// Designated initializer
    ///
    /// - Parameters:
    ///   - type: the storage strategy of cache
    ///   - pathComponents: An array of strings specifying path components in the folder.
    ///     eg. ["abc", "def"] result in <Sandbox>/<Documents or Library/Caches>/abc/def. By default, ["com.lionhylra.CacheManager"]
    public init(type: CacheType, pathComponents: [String] = ["\(Bundle(for: ImageCacheManager.self).bundleIdentifier!).\(String(describing: ImageCacheManager.self))"]) throws {
        switch type {
        case .memory:
            self.memoryCache = NSCache<NSString, UIImage>()
            self.fileManager = nil

        case let .fileSystem(persistent):
            self.memoryCache = nil
            let directory: FileManager.SearchPathDirectory = persistent ? .documentDirectory : .cachesDirectory
            self.fileManager = try FileSessionManager(directory: directory, pathComponents: pathComponents)
        case let .memoryAndFileSystem(persistent):
            self.memoryCache = NSCache<NSString, UIImage>()
            let directory: FileManager.SearchPathDirectory = persistent ? .documentDirectory : .cachesDirectory
            self.fileManager = try FileSessionManager(directory: directory, pathComponents: pathComponents)
        }
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    deinit {
        removeExpiredData(inBackground: false)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    /// Get the cached data by a key. The cached data in memory will be returned first if there is any. Then fetch cached data in file system. If nothing found, return nil.
    ///
    /// - Parameter key: key
    /// - Returns: cached data
    public func image(forKey key: String) -> UIImage? {
        if let image = memoryCache?.object(forKey: key as NSString) {
            return image
        }

        guard let data = fileManager?.data(for: key),
            let (imageData, expirationDate) = ImageCacheManager.unarchive(data: data) else {
                return nil
        }

        if let expirationDate = expirationDate, Date() >= expirationDate {
            removeExpiredData(inBackground: true)
            return nil
        }

        guard let image = UIImage(data: imageData) else {
            return nil
        }

        let decodedImage = image.decoded() ?? image
        memoryCache?.setObject(decodedImage, forKey: key as NSString)
        return decodedImage
    }

    /// This method does the same thing as `public func image(forKey key: String) -> UIImage?` does. The only difference is it put file reading and image decoding code into background.
    public func image(forKey key: String, completion: @escaping (UIImage?) -> Void) {
        let executeCompletion: (UIImage?) -> Void = { image in
            DispatchQueue.main.async {
                completion(image)
            }
        }

        if let image = memoryCache?.object(forKey: key as NSString) {
            completion(image)
            return
        }

        ioQueue.async {
            guard let data = self.fileManager?.data(for: key),
                let (imageData, expirationDate) = ImageCacheManager.unarchive(data: data) else {
                    executeCompletion(nil)
                    return
            }

            if let expirationDate = expirationDate, Date() >= expirationDate {
                self.removeExpiredData(inBackground: true)
                executeCompletion(nil)
                return
            }

            guard let image = UIImage(data: imageData) else {
                executeCompletion(nil)
                return
            }

            let decodedImage = image.decoded() ?? image
            self.memoryCache?.setObject(decodedImage, forKey: key as NSString)
            executeCompletion(decodedImage)
        }
    }

    /// Save a data using a key. Optionally, set a expiration date. If current date is later than expiration date, the cached data will be removed for the key and data(forKey key:) returns nil for this key.
    ///
    /// - Parameters:
    ///   - data: data to cache
    ///   - key: key
    ///   - expirationDate: An Date instance. If nil, the cached data will never be expired unless removeAll() is called or removeData(forKey key:) is called for the key. If the cache manager is initialized to use memory only, `expirationDate` is ignored.
    public func setImage(_ image: UIImage, forKey key: String, expiredAt expirationDate: Date? = nil) {
        let decoded = image.decoded() ?? image
        memoryCache?.setObject(decoded, forKey: key as NSString)
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return
        }
        ioQueue.async {
            guard let data = ImageCacheManager.archive(data: imageData, expirationDate: expirationDate) else { return }
            try? self.fileManager?.save(data: data, withName: key)
        }
    }

    /// Save a data using a key. Optionally, set a expiration delay. If current date is later than expiration date, the cached data will be removed for the key and data(forKey key:) returns nil for this key. If the cache manager is initialized to use memory only, `expirationDate` is ignored.
    ///
    /// - Parameters:
    ///   - data: data to cache
    ///   - key: key
    ///   - expiredAfter: A time interval measured in seconds
    public func setImage(_ image: UIImage, forKey key: String, expiredAfter: TimeInterval) {
        setImage(image, forKey: key, expiredAt: Date() + expiredAfter)
    }

    /// Call this method to delete expired cached files. You can call this method manually at some point. This method will also be called everytime when an instance of CachedManager is initialized.
    public func removeExpiredData(inBackground: Bool) {
        let task = {
            guard let fileManager = self.fileManager, let urls = try? fileManager.allFiles() else {return}

            for url in urls {
                if let wrappedData = try? Data(contentsOf: url), let (_, expirationDate) = ImageCacheManager.unarchive(data: wrappedData) {
                    if let expirationDate = expirationDate, Date() >= expirationDate {
                        try? FileManager.default.removeItem(at: url)
                    }
                }
            }
        }
        if inBackground {
            ioQueue.async(execute: task)
        } else {
            task()
        }
    }

    /// Remove all the cached data both in memory and file system
    public func removeAll() {
        memoryCache?.removeAllObjects()
        ioQueue.async {
            try? self.fileManager?.removeAll()
        }
    }

    /// Remove cached data for specific key
    ///
    /// - Parameter key: key
    public func removeImage(forKey key: String) {
        memoryCache?.removeObject(forKey: key as NSString)
        ioQueue.async {
            try? self.fileManager?.remove(fileName: key)
        }
    }

    @objc private func didReceiveMemoryWarning() {
        memoryCache?.removeAllObjects()
    }

    static func archive(data: Data, expirationDate: Date?) -> Data? {
        let item = CacheItem(data: data, expirationDate: expirationDate)
        if #available(iOS 11.0, *) {
            return try? NSKeyedArchiver.archivedData(withRootObject: item, requiringSecureCoding: false)
        } else {
            return NSKeyedArchiver.archivedData(withRootObject: item)
        }
    }

    static func unarchive(data: Data) -> (Data, Date?)? {
        guard let item = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)) as? CacheItem else {
            return nil
        }
        return (item.data, item.expirationDate)
    }
}

extension ImageCacheManager {

    @objc(ImageCacheManagerCacheItem)
    class CacheItem: NSObject, NSCoding {

        let data: Data
        let expirationDate: Date?

        init(data: Data, expirationDate: Date?) {
            self.data = data
            self.expirationDate = expirationDate
            super.init()
        }

        private struct PropertyKey {
            static let data = "data"
            static let expirationDate = "expirationDate"
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(data, forKey: PropertyKey.data)
            aCoder.encode(expirationDate, forKey: PropertyKey.expirationDate)
        }

        required convenience init?(coder aDecoder: NSCoder) {
            guard let data = aDecoder.decodeObject(forKey: PropertyKey.data) as? Data else {
                return nil
            }
            let expirationDate = aDecoder.decodeObject(forKey: PropertyKey.expirationDate) as? Date
            self.init(data: data, expirationDate: expirationDate)
        }
    }
}
