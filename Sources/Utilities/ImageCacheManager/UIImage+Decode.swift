//
//  UIImage+Decompress.swift
//  Swift3Project
//
//  Created by Yilei on 4/4/17.
//  Copyright © 2017 Yilei He All rights reserved.
//

import UIKit

private let bytesPerPixel = 4
private let bitsPerComponent = 8

extension UIImage {
    public var isDecodable: Bool {
        // do not decode animated images
        if images != nil {
            return false
        }

        // do not decode animated images
        if let cgImage = self.cgImage {
            let alphaInfo = cgImage.alphaInfo
            switch alphaInfo {
            case .first, .last, .premultipliedFirst, .premultipliedLast:
                return false
            default:
                break
            }
        }

        return true
    }

    public func decoded() -> UIImage? {
        if !isDecodable {
            return nil
        }

        guard let cgImage = self.cgImage else {
            return nil
        }

        guard var colorSpace = cgImage.colorSpace  else {
            return nil
        }

        let colorSpaceModel = colorSpace.model

        switch colorSpaceModel {
        case .unknown, .monochrome, .cmyk, .indexed:
            colorSpace =  CGColorSpaceCreateDeviceRGB()
        default:
            break
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = bytesPerPixel * width

        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let cgImageWithoutAlpha = context.makeImage() else {
            return nil
        }

        let imageWithoutAlpha = UIImage(cgImage: cgImageWithoutAlpha, scale: self.scale, orientation: self.imageOrientation)

        return imageWithoutAlpha
    }
}
