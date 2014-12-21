//
//  MainViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var gamesTableView: UITableView!

    var actionableGames: [Game]!
    var waitingGames: [Game]!
    var opponentFbIds: [String]!

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        gamesTableView.dataSource = self
        gamesTableView.delegate = self

        reloadGames()
    }

    // MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let games = actionableGames {
                return games.count
            } else {
                return 0
            }
        } else {
            if let games = waitingGames {
                return games.count
            } else {
                return 0
            }
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Your turn"
        } else {
            return "Their turn"
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GameCell", forIndexPath: indexPath) as UITableViewCell

        var game: Game
        if indexPath.section == 0 {
            game = actionableGames[indexPath.row]
        } else {
            game = waitingGames[indexPath.row]
        }
        if game.player1.objectId == PFUser.currentUser().objectId {
            cell.textLabel?.text = game.player2Name
        } else {
            cell.textLabel?.text = game.player1Name
        }
        cell.detailTextLabel?.text = "Round \(game.currentRoundIndex + 1)"

        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (indexPath.section == 0)
    }

    // MARK: event handlers

    @IBAction func onLogoutButtonTap(sender: AnyObject) {
        PFUser.logOut()

        let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController
        let loginVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginViewController") as? UIViewController
        UIView.transitionFromView(rootVC!.view, toView: loginVC!.view, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: { (finished) -> Void in
            let appDelegate = UIApplication.sharedApplication().delegate
            appDelegate?.window??.rootViewController = loginVC
        })
    }

    // MARK: helpers

    func reloadGames() {
        Game.getGamesForUser(PFUser.currentUser(), block: { (actionableGames, waitingGames) -> Void in
            self.actionableGames = actionableGames
            self.waitingGames = waitingGames
            self.opponentFbIds = []
            for game in (actionableGames + waitingGames) {
                if game.player1.objectId == PFUser.currentUser().objectId {
                    self.opponentFbIds.append(game.player2FbId)
                } else {
                    self.opponentFbIds.append(game.player1FbId)
                }
            }
            self.gamesTableView.reloadData()
        })
    }
}
