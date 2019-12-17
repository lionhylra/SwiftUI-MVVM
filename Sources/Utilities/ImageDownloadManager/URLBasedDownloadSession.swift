//
//  Copyright © 2018 Yilei He All rights reserved.
//

import UIKit

/// This class manages download task using key value mapping where key is the "url" that is used to initiate download and value is a struct that caches URLSessionDownloadTask, ProgressHandler and CompletionHandler.
///
/// The purpose if this design is to easily manage downloading tasks simply using url. Then the user doesn't need to worry about managing URLSessionDownloadTask, ProgressHandler and CompletionHandler himself/herself.
///
/// This class uses ephemeral as configuration for URLSession.
public class URLBasedDownloadSession {

    // MARK: - Nested types
    fileprivate struct Task {
        let downloadTask: URLSessionDownloadTask
        var progressHandler: ProgressHandler?
        var completionHandler: CompletionHandler?
    }

    fileprivate class DownloadSessionDelegate: NSObject {
        weak var downloader: URLBasedDownloadSession!
    }

    // MARK: - typealias
    public typealias CompletionHandler = (_ imageURL: URL?, _ error: Error?) -> Void
    public typealias ProgressHandler = (_ totalBytesWritten: Float, _ totalBytesExpectedToWrite: Float) -> Void

    // MARK: - properties
    public static let `default` = URLBasedDownloadSession()

    lazy fileprivate var downloadSession: URLSession = {
        let delegate = DownloadSessionDelegate()
        delegate.downloader = self
        return URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: delegate, delegateQueue: nil)
    }()

    private let _getTasks: () -> [URL: Task]
    private let _setTasks: ([URL: Task]) -> Void
    fileprivate var tasks: [URL: Task] {
        get {
            return _getTasks()
        }
        set {
            _setTasks(newValue)
        }
    }

    // MARK: - life cycle
    public init() {
        var _tasks: [URL: Task] = [:]
        let internalQueue = DispatchQueue(label: "\(Bundle(for: URLBasedDownloadSession.self).bundleIdentifier!).\(String(describing: URLBasedDownloadSession.self)).queue", attributes: .concurrent)
        _getTasks = {
            return internalQueue.sync { _tasks }
        }
        _setTasks = { newValue in
            internalQueue.async (flags: .barrier) { _tasks = newValue }
        }
    }

    deinit {
        downloadSession.finishTasksAndInvalidate()
    }

    // MARK: - public methods
    public func startDownloadTask(url: URL, progressHandler: ProgressHandler?, completionHandler: CompletionHandler?) {
        /* check suspended task */
        if tasks[url] != nil {
            tasks[url]!.progressHandler = progressHandler
            tasks[url]!.completionHandler = completionHandler
            tasks[url]!.downloadTask.resume()
            return
        }

        /* start new task */
        let downloadTask = downloadSession.downloadTask(with: url)
        downloadTask.resume()
        tasks[url] = Task(downloadTask: downloadTask,
                          progressHandler: progressHandler,
                          completionHandler: completionHandler)
    }

    public func suspendDownloadTask(for url: URL) {
        tasks[url]?.downloadTask.suspend()
    }

    public func cancelDownloadTask(for url: URL) {
        tasks[url]?.downloadTask.cancel()
    }
}

extension URLBasedDownloadSession.DownloadSessionDelegate: URLSessionDownloadDelegate {

    fileprivate func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        guard let url = downloadTask.originalRequest?.url else {
            return
        }
        downloader.tasks[url]?.completionHandler?(location, nil)
        downloader.tasks.removeValue(forKey: url)
    }

    fileprivate func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        guard let url = downloadTask.originalRequest?.url else {
            return
        }
        downloader.tasks[url]?.progressHandler?(Float(totalBytesWritten), Float(totalBytesExpectedToWrite))
    }
}

extension URLBasedDownloadSession.DownloadSessionDelegate: URLSessionTaskDelegate {

    fileprivate func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        guard let url = task.originalRequest?.url else {
            return
        }
        downloader.tasks[url]?.completionHandler?(nil, error)
        downloader.tasks.removeValue(forKey: url)
    }
}
