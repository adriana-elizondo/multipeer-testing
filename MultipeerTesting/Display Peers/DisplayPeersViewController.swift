//
//  ViewController.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/18.
//  Copyright © 2019 EF. All rights reserved.
//

import UIKit

protocol DisplayPeersDisplayLogic : class{
    func updatePeers(viewModel: ListPeers.FetchOnlinePeers.ViewModel)
    func showInvitationAlert(with invitation: Invitation)
    func updateConnectionStatus(with status: ConnectionStatus)
}

class DisplayPeersViewController: UIViewController, DisplayPeersDisplayLogic{
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "peerCell")
        }
    }
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startGame: UIButton!
    
    var interactor: DisplayPeersBusinessLogic?
    var router: (DisplayPeersRoutingLogic & DisplayPeersDataPassing)?
    var peers = [ListPeers.FetchOnlinePeers.ViewModel.DisplayedPeer]()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup()
    {
        let viewController = self
        let interactor = DisplayPeersInteractor()
        let presenter = DisplayPeersPresenter()
        let router = DisplayPeersRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    func updatePeers(viewModel: ListPeers.FetchOnlinePeers.ViewModel) {
        peers = viewModel.displayedPeers
        tableView.reloadData()
    }
    
    func updateConnectionStatus(with status: ConnectionStatus) {
        DispatchQueue.main.async {
            self.statusLabel.text = status.statusText
        }
    }
    
    func showInvitationAlert(with invitation: Invitation) {
        let alertController = UIAlertController(title: "New invitation", message: "This human wants to connect with you!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Do it!", style: .default, handler: { (action) in
            invitation.completionHandler(true)
            self.router?.routeToWhiteboardView()
        }))
        
        alertController.addAction(UIAlertAction(title: "Fuck that guy", style:.destructive, handler: { (action) in
            invitation.completionHandler(false)
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func goToWhiteBoard(_ sender: Any) {
        router?.routeToWhiteboardView()
    }
}

extension DisplayPeersViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peerCell")
        cell?.textLabel?.text = peers[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactor?.sendInvitation(to: peers[indexPath.row])
    }
}

