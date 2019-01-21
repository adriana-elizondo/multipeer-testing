//
//  ViewController.swift
//  MultipeerTesting
//
//  Created by Adriana Elizondo on 2019/1/18.
//  Copyright © 2019 EF. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let connector = Connector.sharedInstance
    private var peers = [String]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startGame: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connector.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }


}

extension ViewController: ConnectorDelegate{
    func didUpdatePeers(with newPeers: [String]) {
        peers = newPeers
        print("I found \(peers)")
        tableView.reloadData()
    }
    
    func didReceiveInvitation(from peer: String, with handler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "New invitation", message: "This human wants to connect with you!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Do it!", style: .default, handler: { (action) in
            handler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Fuck that guy", style:.destructive, handler: { (action) in
            handler(false)
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func didReceiveConnectionError() {
        changeStatusLabel(with: ":s not working, check wifi maybe?")
    }
    
    //Session
    func connecting(to human: String) {
        changeStatusLabel(with: "connecting you to \(human)")
    }
    
    func connectionSuccessful(to human: String) {
        changeStatusLabel(with: "you are connected to \(human))")
    }
    
    func humanDoesntWantYou(this one: String) {
        changeStatusLabel(with: "\(one) said bye bye")
    }
    
    private func changeStatusLabel(with text: String){
        DispatchQueue.main.async {
            self.statusLabel.text = text
        }
    }
    
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peerCell")
        cell?.textLabel?.text = peers[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        connector.sendInvitation(to: peers[indexPath.row])
    }
}

