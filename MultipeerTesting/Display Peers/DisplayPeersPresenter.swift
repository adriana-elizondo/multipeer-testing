//
//  DisplayPeersPresenter.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/28.
//  Copyright © 2019 EF. All rights reserved.
//

import Foundation

protocol DisplayPeersPresentationLogic{
    func presentPeersFound(with viewModel: ListPeers.FetchOnlinePeers.Response)
    func presentPeerInvitation(with viewModel: Invitation)
    func presentStatus(with viewModel: ConnectionStatus)
}

class DisplayPeersPresenter: DisplayPeersPresentationLogic{
    weak var viewController : DisplayPeersDisplayLogic?
    
    func presentPeersFound(with viewModel: ListPeers.FetchOnlinePeers.Response) {
        let onlinePeers = viewModel.onlinePeers
        let displayedPeers = ListPeers.FetchOnlinePeers.ViewModel(displayedPeers: onlinePeers.map{ ListPeers.FetchOnlinePeers.ViewModel.DisplayedPeer(name: $0)})
        
        viewController?.updatePeers(viewModel: displayedPeers)
    }
    
    func presentPeerInvitation(with viewModel: Invitation) {
        viewController?.showInvitationAlert(with: viewModel)
    }
    
    func presentStatus(with viewModel: ConnectionStatus) {
        viewController?.updateConnectionStatus(with: viewModel)
    }
}


