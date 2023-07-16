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
    rightSizeImage = image.pngData()
    while rightSizeImage.count >= 10 * oneMB {
        rightSizeImage = image.jpegData(compressionQuality: 0.1)
    }
    return rightSizeImage
}
