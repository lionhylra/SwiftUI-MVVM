//
//  Copyright © 2018 Carsales Ltd. All rights reserved.
//

import Foundation

extension String {

    /// Initialise a string using it's base64 encoded format
    ///
    /// - Parameters:
    ///   - base64: The base64 encoded string of original string
    ///   - encoding: String encoding, by default it's utf-8
    public init?(base64Encoded base64: String, encoding: String.Encoding = .utf8) {
        guard let data = Data(base64Encoded: base64) else { return nil }
        self.init(data: data, encoding: encoding)
    }

    /// Generate a base64 encoded string from original string
    ///
    /// - Parameter encoding: String encoding, by default it's utf-8
    /// - Returns: base64 encoded string
    public func base64Encoded(encoding: String.Encoding = .utf8) -> String? {
        return data(using: encoding)?.base64EncodedString()
    }

    /// Convert the base64 encoded string back to original string. The base64 encoded string must be generated based on the rule used by `func base64URLEncoded(omitPadding: Bool = false, encoding: String.Encoding = .utf8) -> String?`
    ///
    /// - Parameters:
    ///   - base64: URL compatible base64 encoded string
    ///   - encoding: String encoding, by default it's utf-8
    public init?(base64URLEncoded base64: String, encoding: String.Encoding = .utf8) {
        let standardBase64 = base64.replacingOccurrences(of: "_", with: "/").replacingOccurrences(of: "-", with: "+")
        let padLength = (4 - (standardBase64.count % 4)) % 4
        let standardBase64WithPaddingCharacters = standardBase64 + String(repeating: "=", count: padLength)
        self.init(base64Encoded: standardBase64WithPaddingCharacters)
    }

    /// Generate a base64 encoded string from original string. In addition, repace "/" with "_" and "+" with "-" to make the result encoded string compatible to be part of URL.
    ///
    /// - Parameters:
    ///   - omitPadding: This value is false by default. If true, no "=" will be appended when the result string is not aligned to 4 characters. If false, "=" will be appended to the end of result string to make sure "result's count % 4 == 0".
    ///   - encoding: String encoding, by default it's utf-8
    /// - Returns: the generated encoded string.
    public func base64URLEncoded(omitPadding: Bool = false, encoding: String.Encoding = .utf8) -> String? {
        var result = self.base64Encoded()?.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "+", with: "-")
        if omitPadding {
            result = result?.replacingOccurrences(of: "=", with: "")
        }
        return result
    }
}
