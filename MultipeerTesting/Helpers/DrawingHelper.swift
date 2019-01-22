//
//  DrawingHelper.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/21.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation
import UIKit

class DrawingHelper{
    var newStroke: Stroke?
    func drawLine(from fromPoint: CGPoint,
                  to toPoint: CGPoint,
                  withBrushWidth brushWidth: CGFloat,
                  andColor color: CGColor,
                  inView parent: UIView,
                  andImage imageToDrawIn: UIImageView,
                  finalImage: UIImageView){
        
        DispatchQueue.main.async {
            UIGraphicsBeginImageContext(parent.frame.size)
            guard let context = UIGraphicsGetCurrentContext() else {
                return
            }
            
            imageToDrawIn.image?.draw(in: parent.bounds)
            context.move(to: fromPoint)
            context.addLine(to: toPoint)
            
            context.setLineCap(.round)
            context.setBlendMode(.normal)
            context.setLineWidth(brushWidth)
            context.setStrokeColor(color)
            
            context.strokePath()
            
            imageToDrawIn.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.mergeImages(with: finalImage, temporary: imageToDrawIn, in: parent.frame)
        }
    }
    
    func mergeImages(with main: UIImageView, temporary: UIImageView, in frame: CGRect){
        UIGraphicsBeginImageContext(main.frame.size)
        main.image?.draw(in: frame, blendMode: .normal, alpha: 1.0)
        temporary.image?.draw(in: frame, blendMode: .normal, alpha: 1.0)
        main.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        temporary.image = nil
    }
    
    func convertPoints(fromStroke stroke: Stroke, to bounds: CGRect) -> (originPoint: CGPoint, destinationPoint: CGPoint){
        let x = (bounds.size.width / stroke.bounds.size.width)
        let y = (bounds.size.height / stroke.bounds.size.height)
        let originX = x * stroke.originPoint.x
        let originY = y * stroke.originPoint.y
        
        let destinationX = x * stroke.lastPoint.x
        let destinationY = y * stroke.lastPoint.y
        
        return (CGPoint(x: originX, y: originY), CGPoint(x: destinationX, y: destinationY))

    }
    
   
}
