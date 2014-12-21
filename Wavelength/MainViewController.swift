//
//  MainViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FBFriendPickerDelegate {

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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentNewGameView" {
            let vc = segue.destinationViewController as NewGameViewController
            vc.delegate = self
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("GameCell", forIndexPath: indexPath) as GameCell

        var game: Game
        if indexPath.section == 0 {
            game = actionableGames[indexPath.row]
        } else {
            game = waitingGames[indexPath.row]
        }
        cell.game = game

        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (indexPath.section == 0)
    }

    // MARK: FBFriendPickerDelegate

    func facebookViewControllerCancelWasPressed(sender: AnyObject!) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func facebookViewControllerDoneWasPressed(sender: AnyObject!) {
        let vc = sender as NewGameViewController
        assert(vc.selection.count == 1, "must have selected exactly one fb friend")
        let friendFbId = vc.selection[0]["id"]

        let query = PFUser.query()
        query.whereKey("fbId", equalTo: friendFbId)
        query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if error == nil {
                let game = Game()
                game.player1 = PFUser.currentUser()
                game.player1Name = game.player1.objectForKey("name") as String
                game.player1FbId = game.player1.objectForKey("fbId") as String
                game.player2 = object as PFUser
                game.player2Name = game.player2.objectForKey("name") as String
                game.player2FbId = game.player2.objectForKey("fbId") as String
                game.currentRoundIndex = 0
                game.currentPlayer = PFUser.currentUser()
                game.saveInBackgroundWithBlock { (succeeded, error) -> Void in
                    if succeeded {
                        Round.newRoundInGame(game, index: 0, block: { (newRound) -> Void in
                            self.actionableGames.append(game)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
                }
            }
        }
    }

    func friendPickerViewController(friendPicker: FBFriendPickerViewController!, shouldIncludeUser user: FBGraphUser!) -> Bool {
        if let opponentFbIds = opponentFbIds {
            return !contains(opponentFbIds, user.objectID)
        } else {
            return true
        }
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
