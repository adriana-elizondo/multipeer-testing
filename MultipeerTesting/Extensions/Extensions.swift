//
//  Extensions.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/18.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation

extension Array{
    mutating func findAndRemoveElement(matching: @escaping (Element) -> Bool) -> Element?{
        for (index, element) in self.enumerated(){
            if matching(element){
                self.remove(at: index)
                return element
            }
        }
        
        return nil
    }
}
