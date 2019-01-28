//
//  PeerToPeerService.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/18.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation
import MultipeerConnectivity

typealias InvitationHandler = (handler: (Bool, MCSession?) -> Void, peerName: String)

protocol ConnectorDelegate: class{
    func didUpdatePeers(with newPeers: [String])
    func didReceiveInvitation(from peer: String, with handler: @escaping (Bool) -> Void)
    func didReceiveConnectionError()
    func connecting(to human: String)
    func connectionSuccessful(to human: String)
    func humanDoesntWantYou(this one: String)
}

protocol DrawingDelegate: class{
    func didReceiveNewEdit(with record: EditRecord)
}

class Connector: NSObject{
    static let sharedInstance = Connector()
    
    private let serviceType = "drawing-game"
    private let peerId = MCPeerID(displayName: UIDevice.current.name)// customizable later
    
    private var advertiser: Advertiser?
    private var browser : Browser?
    private var sessionManager : SessionManager?
    
    weak var delegate: ConnectorDelegate?
    weak var drawingDelegate: DrawingDelegate?
    
    private var currentPeers = [MCPeerID]()
    private var invitationRequests : Array = [InvitationHandler]()
    private var currentEdits = [EditRecord]()
    
    override init() {
        super.init()
        advertiser = Advertiser(with: peerId, serviceType: serviceType, and: self)
        browser = Browser(with: peerId, serviceType: serviceType, and: self)
        sessionManager = SessionManager(with: peerId, and: self)
    }
    
    func sendInvitation(to peer: String){
        if let peer = currentPeers.first(where: {$0.displayName == peer}){
            browser?.invitePeer(with: peer, to: sessionManager!.session)
        }else{
            //error?
        }
    }
    
    func sendEditRecord(editRecord: EditRecord){
        currentEdits.append(editRecord)
        drawLatestEdit()
        sessionManager?.sendDataToPeers(data: RecordParser.recordToData(editRecord: editRecord))
    }
    
    func drawLatestEdit(){
        if let latestEdit = RecordParser.editToDraw(with: &currentEdits){
            drawingDelegate?.didReceiveNewEdit(with: latestEdit)
        }
    }
}

extension Connector: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        //Display error maybe ask user to check connection
        delegate?.didReceiveConnectionError()
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationRequests.append((invitationHandler,peerID.displayName))
        delegate?.didReceiveInvitation(from: peerID.displayName, with: { [weak self] (accepted) in
            let request = self?.invitationRequests.findAndRemoveElement(matching: {$0.peerName == peerID.displayName})
            request?.handler(accepted, self?.sessionManager?.session)
        })
    }
}

extension Connector: MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        //error in connection
        delegate?.didReceiveConnectionError()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        currentPeers.append(peerID)
        delegate?.didUpdatePeers(with: currentPeers.map{$0.displayName})
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        _ = currentPeers.findAndRemoveElement(matching: {$0 == peerID})
        delegate?.didUpdatePeers(with: currentPeers.map{$0.displayName})
    }
    
}

extension Connector: MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            delegate?.connectionSuccessful(to: peerID.displayName)
        case .connecting:
            delegate?.connecting(to: peerID.displayName)
        case .notConnected:
            delegate?.humanDoesntWantYou(this: peerID.displayName)
            
        default:break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let record = RecordParser.dataToEditRecord(data: data){
            currentEdits.append(record)
            drawLatestEdit()
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

