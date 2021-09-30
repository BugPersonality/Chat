//
//  UIImage + Extension.swift
//  iChat
//
//  Created by Данил Дубов on 27.09.2021.
//

import UIKit

extension UIImage {
    var scaledToSafeUploadSize: UIImage? {
        let maxImageSideLen: CGFloat = 480

        let largerSide: CGFloat = max(size.width, size.height)
        let ratioScale: CGFloat = largerSide > maxImageSideLen ? largerSide / maxImageSideLen : 1
        let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)

        return image(scaledTo: newImageSize)
    }

    func image(scaledTo size: CGSize) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }

        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        draw(in: CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
