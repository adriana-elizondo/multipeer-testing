//
//  EditRecord.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/18.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation
import UIKit

struct Stroke : Codable{
    enum CodingKeys: CodingKey{
        case OriginPoint, LastPoint, Color, BrushWidth, Opacity, Bounds
    }
    
    var originPoint: CGPoint
    var lastPoint : CGPoint
    var color : UIColor = UIColor.black
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var bounds : CGRect
    
    init(with origin: CGPoint, in bounds: CGRect){
        originPoint = origin
        lastPoint = origin
        self.bounds = bounds
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        originPoint = try values.decode(CGPoint.self, forKey: .OriginPoint)
        lastPoint = try values.decode(CGPoint.self, forKey: .LastPoint)
        color = try values.decode(Color.self, forKey: .Color).uiColor
        brushWidth = try values.decode(CGFloat.self, forKey: .BrushWidth)
        opacity = try values.decode(CGFloat.self, forKey: .Opacity)
        bounds = try values.decode(CGRect.self, forKey: .Bounds)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(originPoint, forKey: .OriginPoint)
        try container.encode(lastPoint, forKey: .LastPoint)
        try container.encode(Color(uiColor: color), forKey: .Color)
        try container.encode(brushWidth, forKey: .BrushWidth)
        try container.encode(opacity, forKey: .Opacity)
        try container.encode(bounds, forKey: .Bounds)
    }
}

struct Color : Codable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(uiColor : UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}

enum Edit<S: Codable> : Codable{
    case addStroke(S)
    
    enum CodingKeys: CodingKey {
        case AddStroke
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let addStrokeValue =  try container.decode(S.self, forKey: .AddStroke)
        self = .addStroke(addStrokeValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .addStroke(let stroke):
            try container.encode(stroke, forKey: .AddStroke)
        }
    }
}
struct EditRecord : Codable{
    let edit : Edit<Stroke>
    let logicalTimeStamp : Int64 = 0
    let timeStamp : Int64 = Int64(Date().timeIntervalSince1970)
    let collaboratorId = UIDevice.current.identifierForVendor
    
    static func <(lhs: EditRecord, rhs: EditRecord) -> Bool {
        if lhs.logicalTimeStamp != rhs.logicalTimeStamp {
            return lhs.logicalTimeStamp < rhs.logicalTimeStamp
        }
        else if lhs.timeStamp != rhs.timeStamp {
            return lhs.timeStamp < rhs.timeStamp
        }
        
        //Shouldnt get here
        return false
    }
}

struct RecordParser{
    static func editToDraw(with records: inout ([EditRecord])) -> EditRecord?{
        records = records.sorted(by: {$0 < $1})
        return records.popLast()
    }
    
    static func dataToEditRecord(data: Data) -> EditRecord?{
        let decoder = JSONDecoder()
        let result = try! decoder.decode(EditRecord.self, from: data)
        return result
    }
    
    static func recordToData(editRecord: EditRecord) -> Data{
        let encoder = JSONEncoder()
        let data = try! encoder.encode(editRecord)
        return data
    }
}
