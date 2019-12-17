//
//  DebouncingManager.swift
//  YHDevKit2
//
//  Created by Yilei He on 2/5/19.
//  Copyright © 2019 lionhylra. All rights reserved.
//

import Foundation

/// This is a manager that debounce a sequence of tasks. Debouncing enforces that a function not be called again until a certain amount of time has passed without it being called. As in "execute this function only if 100 milliseconds have passed without it being called."
public class DebouncingManager {

    public var delay: TimeInterval
    private let queue: DispatchQueue

    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    private var workItem: DispatchWorkItem?

    public var hasPendingAction: Bool {
        return workItem != nil
    }

    /// Debounce an action. It will only be executed once either when time pass the waiting period or by calling `executeImmediately()` during waiting period. And it can be cancelled during the waiting period either by another action or by calling `cancelAction()` manually. The action will not be retained.
    ///
    /// - Parameter action: The action to execute.
    public func commit(action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: { [weak self] in
            action()
            self?.workItem?.cancel() // A workItem can only be executed once.
            self?.workItem = nil // A workItem must be discarded once it is executed.
        })
        queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }

    /// Cancel any pending action.
    public func cancelAction() {
        workItem?.cancel()
        workItem = nil
    }

    /// Execute a pending action immediately if there is one.
    ///
    /// - Parameter synchronously: If true, the execution of action will be finished upon return of this function. If false, it is dispatched to the queue that is passed in initialiser without delay. It is false by default.
    public func executeImmediately(synchronously: Bool = false) {
        if let workItem = workItem {
            if synchronously {
                workItem.perform()
            } else {
                queue.async(execute: workItem)
            }
        }
    }
}
