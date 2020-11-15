//
//  ImageViewController.swift
//  Pixels
//
//  Created by thomsmed on 12/11/2020.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var modifiedImageView: UIImageView!
    @IBOutlet weak var pixelGridView: PixelGridView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setImage(UIImage(named: "apple-logo")!)
    }
    
    private func setImage(_ image: UIImage) {
        imageView.image = image

        let targetSize = CGSize(width: 64, height: 64)
        let resizedImage = image.resize(toFit: targetSize)

        modifiedImageView.image = resizedImage

        guard let cgImage = resizedImage.cgImage else {
            return
        }
        
        if let pixelGrid = cgImage.pixelColors() {
            pixelGridView.pixelGrid = pixelGrid
        }
    }
}

// MARK: UIImage.resize
extension UIImage {
    func resize(toFit targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

// MARK: CGImage.pixelColor
extension CGImage {
    func pixelColor(at point: CGPoint) -> CGColor? {
        guard let dataProvider = dataProvider,
              let pixelData = dataProvider.data,
              let pixelPointer = CFDataGetBytePtr(pixelData) else {
            return nil
        }

        let bytesPerPixel = bitsPerPixel / 8
        let pixelInfoIndex = Int(point.y) * bytesPerRow + Int(point.x) * bytesPerPixel

        let r = CGFloat(pixelPointer[pixelInfoIndex + 0]) / CGFloat(2 << (bitsPerComponent - 1))
        let g = CGFloat(pixelPointer[pixelInfoIndex + 1]) / CGFloat(2 << (bitsPerComponent - 1))
        let b = CGFloat(pixelPointer[pixelInfoIndex + 2]) / CGFloat(2 << (bitsPerComponent - 1))
        let a = CGFloat(pixelPointer[pixelInfoIndex + 3]) / CGFloat(2 << (bitsPerComponent - 1))
        
        return CGColor(red: r, green: g, blue: b, alpha: a)
    }
}

// MARK: CGImage.pixelColors
extension CGImage {
    func pixelColors() -> [[CGColor]]? {
        guard let dataProvider = dataProvider,
              let pixelData = dataProvider.data,
              let pixelPointer = CFDataGetBytePtr(pixelData) else {
            return nil
        }
        
        let byteCount = CFDataGetLength(pixelData)
        let bytesPerPixel = bitsPerPixel / 8
        let pixelOffsets = stride(from: 0, to: byteCount, by: bytesPerPixel)

        var pixelGrid = [[CGColor]]()
        
        for offset in pixelOffsets {
            let rowIndex = offset / bytesPerRow

            if rowIndex + 1 > pixelGrid.count {
                pixelGrid.append([CGColor]())
            }

            let r = CGFloat(pixelPointer[offset + 0]) / CGFloat(2 << (bitsPerComponent - 1))
            let g = CGFloat(pixelPointer[offset + 1]) / CGFloat(2 << (bitsPerComponent - 1))
            let b = CGFloat(pixelPointer[offset + 2]) / CGFloat(2 << (bitsPerComponent - 1))
            let a = CGFloat(pixelPointer[offset + 3]) / CGFloat(2 << (bitsPerComponent - 1))

            pixelGrid[rowIndex].append(CGColor(red: CGFloat(r),
                                               green: CGFloat(g),
                                               blue: CGFloat(b),
                                               alpha: CGFloat(a)))
        }
        
        return pixelGrid
    }
}
