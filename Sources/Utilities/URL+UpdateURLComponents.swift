//
//  Copyright © 2019 Carsales Ltd. All rights reserved.
//

import Foundation

extension URL {

    /// This is a convenience method for updating URL components without converting URL to URLComponents and converting back to URL.
    ///
    /// - Parameter updateHandler: This closure provide a point for you to update URLComponents for the url.
    public mutating func updateComponents(_ updateHandler: (inout URLComponents) -> Void) {
        self = self.updatingComponents(updateHandler)
    }

    /// Returns a URL by updating its URLComponents.
    ///
    /// - Parameter updateHandler: This closure provide a point for you to update URLComponents for the url.
    /// - Returns: A new URL
    public func updatingComponents(_ updateHandler: (inout URLComponents) -> Void) -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        updateHandler(&urlComponents)
        return urlComponents.url ?? self
    }
}
