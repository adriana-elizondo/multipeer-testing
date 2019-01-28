//
//  DisplayPeersRouter.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/28.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation

protocol DisplayPeersRoutingLogic{
    func routeToWhiteboardView()
}

protocol DisplayPeersDataPassing {
    
}

class DisplayPeersRouter: DisplayPeersRoutingLogic, DisplayPeersDataPassing{
    weak var viewController: DisplayPeersViewController?
    var dataStore : DisplayPeersDataStore?
    
    func routeToWhiteboardView(){
        let whiteBoardController = WhiteBoardViewController(nibName: nil)
        viewController?.navigationController?.pushViewController(whiteBoardController, animated: true)
    }
}
