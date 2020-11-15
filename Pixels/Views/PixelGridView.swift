//
//  PixelGridView.swift
//  Pixels
//
//  Created by thomsmed on 12/11/2020.
//

import Foundation
import UIKit

class PixelGridView: UIView {
    var pixelGrid: [[CGColor]] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ rect: CGRect) {
        guard let first = pixelGrid.first else {
            return
        }

        let countY = CGFloat(pixelGrid.count)
        let countX = CGFloat(first.count)
        
        var length = CGFloat(rect.height)
        var paddingX = CGFloat((rect.width - length) / 2)
        var paddingY = CGFloat(0)
        if rect.width < length {
            length = CGFloat(rect.width)
            paddingX = CGFloat(0)
            paddingY = CGFloat((rect.height - length) / 2)
        }
        
        let pw = length / countX
        let ph = length / countY

        for (rowIndex, pixelRow) in pixelGrid.enumerated() {
            for (index, color) in pixelRow.enumerated() {
                UIColor(cgColor: color).setFill()
                UIRectFill(CGRect(x: CGFloat(index) * pw + paddingX, y: CGFloat(rowIndex) * ph + paddingY, width: pw, height: ph))
            }
        }
    }
}
