//
//  Browser.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/18.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Browser: NSObject{
    private let serviceBrowser : MCNearbyServiceBrowser
    
    deinit {
        serviceBrowser.stopBrowsingForPeers()
    }
    
    init(with peerId: MCPeerID, serviceType: String, and delegate: MCNearbyServiceBrowserDelegate) {
        serviceBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
        super.init()
        serviceBrowser.delegate = delegate
        serviceBrowser.startBrowsingForPeers()
    }
    
    func invitePeer(with id: MCPeerID, to session: MCSession){
        serviceBrowser.invitePeer(id, to: session, withContext: nil, timeout: 20)
    }
}
