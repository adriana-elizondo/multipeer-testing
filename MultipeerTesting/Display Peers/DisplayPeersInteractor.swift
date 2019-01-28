//
//  DisplayPeersInteractor.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/28.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol DisplayPeersBusinessLogic{
    func sendInvitation(to peer: ListPeers.FetchOnlinePeers.ViewModel.DisplayedPeer)
}

protocol DisplayPeersDataStore {
    var peers: [Peer]? {get}
}

class DisplayPeersInteractor: DisplayPeersBusinessLogic, DisplayPeersDataStore{
    var peers: [Peer]?
    var presenter: DisplayPeersPresentationLogic?
    var connector = Connector.sharedInstance
    
    init() {
        connector.delegate = self
    }
   
    func sendInvitation(to peer: ListPeers.FetchOnlinePeers.ViewModel.DisplayedPeer) {
        connector.sendInvitation(to: peer.name)
    }
}

extension DisplayPeersInteractor: ConnectorDelegate{
    func didUpdatePeers(with newPeers: [String]) {
        presenter?.presentPeersFound(with: ListPeers.FetchOnlinePeers.Response(onlinePeers: newPeers))
    }
    
    func didReceiveInvitation(from peer: String, with handler: @escaping (Bool) -> Void) {
        presenter?.presentPeerInvitation(with: Invitation(peerName: peer, completionHandler: handler))
    }
    
    func didReceiveConnectionError() {
        presenter?.presentStatus(with: .ConnectionError)
    }
    
    //Session
    func connecting(to human: String) {
        presenter?.presentStatus(with: .Connecting(human))
    }
    
    func connectionSuccessful(to human: String) {
        presenter?.presentStatus(with: .Connected(human))
    }
    
    func humanDoesntWantYou(this one: String) {
        presenter?.presentStatus(with: .Disconnected(one))
    }
    
}

