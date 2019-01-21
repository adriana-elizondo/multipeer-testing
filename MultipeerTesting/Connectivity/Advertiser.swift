//
//  Advertiser.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/18.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Advertiser: NSObject{
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    init(with peerId: MCPeerID, serviceType: String, and delegate: MCNearbyServiceAdvertiserDelegate){
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)
        super.init()
        serviceAdvertiser.delegate = delegate
        serviceAdvertiser.startAdvertisingPeer()
    }

}
