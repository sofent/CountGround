//
//  UIImage++.swift
//  CountGround
//
//  Created by 衡阵 on 2022/5/30.
//

import UIKit

extension UIImage {
    func matrix(_ rows: Int, _ columns: Int) -> [UIImage] {
        let y = (size.height / CGFloat(rows)).rounded()
        let x = (size.width / CGFloat(columns)).rounded()
        var images: [UIImage] = []
        images.reserveCapacity(rows * columns)
        guard let cgImage = cgImage else { return [] }
        (0..<rows).forEach { row in
            (0..<columns).forEach { column in
                var width = Int(x)
                var height = Int(y)
                if row == rows-1 && size.height.truncatingRemainder(dividingBy: CGFloat(rows)) != 0 {
                    height = Int(size.height - size.height / CGFloat(rows) * (CGFloat(rows)-1))
                }
                if column == columns-1 && size.width.truncatingRemainder(dividingBy: CGFloat(columns)) != 0 {
                    width = Int(size.width - (size.width / CGFloat(columns) * (CGFloat(columns)-1)))
                }
                if let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: column * Int(x), y:  row * Int(x)), size: CGSize(width: width, height: height))) {
                    images.append(UIImage(cgImage: image, scale: scale, orientation: imageOrientation))
                }
            }
        }
        return images
    }
    
    func toSquare() -> UIImage {
        let toSize = min(size.height,size.width)
        guard let cgImage = cgImage else { return UIImage() }
        if let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: size.height > size.width ? 0 : (size.width-size.height) / 2, y: size.width > size.height ? 0 : (size.height - size.width)/2), size: CGSize(width: toSize, height: toSize))) {
            return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
        }
        return UIImage()
    }
}
