//
//  Copyright (c) 2015 Carsales.com.au. All rights reserved.
//

import UIKit

/// The FileSessionManager is designed to provide a set of interfaces to read and write Data based on file name. The directory where all operations happen is determined at the stage of initialisation. File names could be any string including URL.
public struct FileSessionManager {
    // MARK: - Properties
    public static let `default`: FileSessionManager = try! FileSessionManager()

    fileprivate let pathComponents: [String]
    fileprivate let directory: FileManager.SearchPathDirectory

    public let directoryURL: URL
    fileprivate let fileManager: FileManager = FileManager.default

    public var encodeFileNameIntoBase64 = true
    // MARK: - Initializers
    public init(directory: FileManager.SearchPathDirectory = .documentDirectory, pathComponents: [String] = []) throws {
        self.pathComponents = pathComponents
        self.directory = directory
        guard var rootURL = fileManager.urls(for: directory, in: .userDomainMask).first else {
            throw NSError(domain: "FileSessionManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get url for directory \(directory) in user domain"])
        }

        for component in pathComponents {
            rootURL.appendPathComponent(component)
        }

        try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true, attributes: nil)

        self.directoryURL = rootURL
    }

    // MARK: - File Operation Methods
    public func url(for fileName: String) -> URL? {
        if fileName.isEmpty { return nil }
        return directoryURL.appendingPathComponent(encodeFileNameIntoBase64 ? (fileName.base64URLEncoded() ?? fileName) : fileName, isDirectory: false)
    }

    public func fileExists(fileName: String) -> Bool {
        return data(for: fileName) != nil
    }

    public func data(for fileName: String) -> Data? {
        return url(for: fileName).flatMap { try? Data(contentsOf: $0)}
    }

    public func save(data: Data, withName fileName: String) throws {
        guard let url = url(for: fileName) else { return }
        try data.write(to: url)
    }

    /// This method moves a file from given file URL to the working directory
    ///
    /// - Parameters:
    ///   - sourceURL: The source location of the file to be moved
    ///   - fileName: The file name to be used when save to working directory
    /// - Throws: Any error that may occur when moving the file
    public func save(byMovingDataFrom sourceURL: URL, withName fileName: String) throws {
        guard let url = url(for: fileName) else { return }
        try fileManager.moveItem(at: sourceURL, to: url)
    }

    public func remove(fileName: String) throws {
        guard let url = url(for: fileName) else { return }
        try fileManager.removeItem(at: url)
    }

    public func rename(fileFromOldName oldName: String, toNewName newName: String) throws {
        guard let oldURL = url(for: oldName), let newURL = url(for: newName) else { return }
        try fileManager.moveItem(at: oldURL, to: newURL)
    }

    /// List all the files in the directory
    ///
    /// - throws: errors thrown by contentsOfDirectory(at: , includingPropertiesForKeys: , options: )
    ///
    /// - returns: An array of URL
    public func allFiles() throws -> [URL] {
        return try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    }

    /// Remove all files in the directory
    ///
    /// - throws: error could be generated when list all files or when remove a file
    public func removeAll() throws {
        let fileUrls = try allFiles()
        var error: Error?
        for url in fileUrls {
            do {
                try fileManager.removeItem(at: url)
            } catch let _error {
                error = _error
            }
        }
        if let error = error {
            throw error
        }
    }
}
