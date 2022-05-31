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
                //print( CGPoint(x: column * Int(x), y:  row * Int(y)))
                if let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: column * Int(x), y:  row * Int(y)), size: CGSize(width: width, height: height))) {
                    images.append(UIImage(cgImage: image, scale: scale, orientation: imageOrientation))
                }
            }
        }
        return images
    }
    
    func toSquare() -> UIImage {
        let toSize = min(size.height,size.width)
        guard let cgImage = cgImage else { return UIImage() }
        if let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: size.height > size.width ? 0 : (size.width-size.height) / 2, y: size.height > size.width ? (size.height - size.width)/2 : 0), size: CGSize(width: toSize, height: toSize))) {
            return UIImage(cgImage: image, scale: scale, orientation: .up)
        }
        return UIImage()
    }

}


extension UIImage {

    func fixedOrientation() -> UIImage {
        
        if imageOrientation == .up{
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:           
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by:CGFloat(Double.pi))
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
            break
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up,.down,.left,.right:
            break
        @unknown default:
           break
        }
        
        let cgImage = cgImage!
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: cgImage.bytesPerRow, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left,.leftMirrored,.right,.rightMirrored:
            ctx.draw(cgImage,in:CGRect(x: 0, y: 0, width: size.height, height: size.width))
            break
        default:
            ctx.draw(cgImage,in:CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        let cgImageN: CGImage = ctx.makeImage()!
        
        return UIImage(cgImage: cgImageN)
    }
}


extension UIImage {
    func withColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }
        color.setFill()
        ctx.translateBy(x: 0, y: size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.clip(to: CGRect(x: 0, y: 0, width: size.width, height: size.height), mask: cgImage)
        ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let colored = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return colored
    }
}
