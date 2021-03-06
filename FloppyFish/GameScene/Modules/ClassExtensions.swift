//
//  ClassExtensions.swift
//  FloppyFish
//
//  Created by Colin Morrison on 10/12/2021.
//

import SpriteKit

extension SKShapeNode {

    func shadow(color: UIColor, size: CGSize, width: CGFloat, cornerRadius: CGFloat) {
        let shadow = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)

        shadow.zPosition = 100
        shadow.lineWidth = width

        shadow.fillColor = .clear
        shadow.strokeColor = color
        shadow.alpha = 0.5

        addChild(shadow)
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
