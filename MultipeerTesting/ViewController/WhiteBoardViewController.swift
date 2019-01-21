//
//  WhiteboardViewController.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/18.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation
import UIKit

class WhiteBoardViewController: UIViewController{
    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var newStroke: Stroke?
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    override func viewDidLoad() {
        Connector.sharedInstance.drawingDelegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        swiped = false
        lastPoint = touch.location(in: view)
        newStroke = Stroke(with: lastPoint, in: view.bounds)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        swiped = true
        let currentPoint = touch.location(in: view)
        drawLine(from: lastPoint, to: currentPoint, with: brushWidth, and: color.cgColor)
        
        lastPoint = currentPoint
        newStroke?.lastPoint = currentPoint
        
        guard newStroke != nil else {return}
        let editRecord = EditRecord(edit: Edit.addStroke(newStroke!))
        Connector.sharedInstance.sendEditRecord(editRecord: editRecord)
        newStroke?.originPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLine(from: lastPoint, to: lastPoint, with: brushWidth, and: color.cgColor)
        }
        
        mergeImages()
        newStroke = nil
    }
    
    private func mergeImages(){
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: view.frame, blendMode: .normal, alpha: 1.0)
        tempImageView?.image?.draw(in: view.frame, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    private func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint, with brushWidth: CGFloat, and color: CGColor){
        DispatchQueue.main.async {
        UIGraphicsBeginImageContext(self.view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        self.tempImageView.image?.draw(in: self.view.bounds)
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color)
        
        context.strokePath()
            
        self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        self.tempImageView.alpha = self.opacity
        UIGraphicsEndImageContext()
        
        self.mergeImages()
        }
    }
}

extension WhiteBoardViewController: DrawingDelegate{
    func didReceiveNewEdit(with record: EditRecord) {
        switch record.edit {
        case .addStroke(let stroke):
           drawLine(with: stroke)
        }
    }
    
    func drawLine(with stroke: Stroke){
        DispatchQueue.main.async {
            let originView = UIView(frame: stroke.bounds)
            let originPoint = self.view.convert(stroke.originPoint, from: originView)
            let destinationPoint = self.view.convert(stroke.lastPoint, from: originView)
            self.drawLine(from: originPoint, to: destinationPoint, with: stroke.brushWidth, and: stroke.color.cgColor)
            self.lastPoint = destinationPoint
        }
    }
}
