//
//  CompressImage.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 2/2/2023.
//

import Foundation
import UIKit

func compressImage(_ image: UIImage, defaultSize: Int = 1 * 1000 * 1000) -> Data? {
    let oneMB = defaultSize // 1 MB default
    var rightSizeImage: Data!
    guard let currentImage = image.pngData() else { return nil }
    if currentImage.count >= 10 * oneMB {
        rightSizeImage = image.jpegData(compressionQuality: 0.0001)
        print("image size too large")
    } else if currentImage.count >= oneMB {
        rightSizeImage = image.jpegData(compressionQuality: 0.01) // image size / 100
    } else if currentImage.count >= oneMB / 10 {
        rightSizeImage = image.jpegData(compressionQuality: 0.1)
    } else {
        rightSizeImage = image.jpegData(compressionQuality: 1)
    }
    return rightSizeImage
}
