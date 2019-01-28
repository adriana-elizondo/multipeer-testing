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
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    var lastPoint = CGPoint.zero
    var swiped = false
    var color = UIColor.black
    var brushWidth: CGFloat = 10.0

    var newStroke: Stroke?
    var drawingHelper = DrawingHelper()
    
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
    
        lastPoint = currentPoint
        newStroke?.lastPoint = currentPoint
        
        guard newStroke != nil else {return}
        let editRecord = EditRecord(edit: Edit.addStroke(newStroke!))
        Connector.sharedInstance.sendEditRecord(editRecord: editRecord)
        newStroke?.originPoint = currentPoint
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
        let points = drawingHelper.convertPoints(fromStroke: stroke, to: view.bounds)
        drawingHelper.drawLine(from: points.originPoint, to: points.destinationPoint, withBrushWidth: brushWidth, andColor: color.cgColor, inView: view, andImage: tempImageView, finalImage: mainImageView)
        lastPoint = points.destinationPoint
    }
}
