//
//  DisplayPeersModels.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/28.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation

enum ListPeers{
    enum FetchOnlinePeers{
        struct Response {
            var onlinePeers : [String]
        }
        
        struct ViewModel {
            struct DisplayedPeer
            {
                var name: String
            }
            
            var displayedPeers: [DisplayedPeer]
        }
    }
}

struct Invitation{
    var peerName: String
    var completionHandler: (Bool) -> Void
}

enum ConnectionStatus{
    case Connecting(String), Connected(String), Disconnected(String), ConnectionError
    
    var statusText: String{
        switch self {
        case .Connected(let peer):
            return "You are connected to \(peer)"
        case .Connecting(let peer):
            return "You are connecting to \(peer)"
        case .Disconnected(let peer):
            return "You lost connection to \(peer)"
        case .ConnectionError:
            return "There has been an error. Check your Wifi or Bluetooth and try again (:"
        }
    }
}
