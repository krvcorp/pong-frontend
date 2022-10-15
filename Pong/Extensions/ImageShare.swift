//
//  ImageShare.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/27/22.
//
import SwiftUI
import Foundation
import SwiftyImage

extension View {
    func textToImage(drawText text: String, atPoint point: CGPoint) -> UIImage {
        let backgroundColor = UIImage.size(width: 1170, height: 2532)
          .color(.red)
          .border(color: .red)
          .image  // generate UIImage
        
        let textContainerColor = UIImage.size(width: 1170 - 50, height: 2532 / 3)
          .color(.white)
          .border(color: .white)
          .image  // generate UIImage
        
        
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 50)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(textContainerColor.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        textContainerColor.draw(in: CGRect(origin: CGPoint.zero, size: textContainerColor.size))

        let rect = CGRect(origin: point, size: textContainerColor.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
//        let imageToReturn = newImage! + backgroundColor
//        return imageToReturn
    }
}
