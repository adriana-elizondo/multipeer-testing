//
//  SessionManager.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/18.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class SessionManager: NSObject{
    var peerId: MCPeerID
    var delegate : MCSessionDelegate
    
    lazy var session: MCSession = {
        let session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = delegate
        return session
    }()
    
    init(with id: MCPeerID, and sessionDelegate: MCSessionDelegate){
        peerId = id
        delegate = sessionDelegate
    }
    
    func sendDataToPeers(data: Data){
        guard session.connectedPeers.count > 0 else{
            //TODO! display error
            return
        }
        
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
}
