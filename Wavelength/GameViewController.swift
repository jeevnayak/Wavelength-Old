//
//  GameViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/24/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

protocol GameDelegate {
    func gameTurnCancelled(sender: AnyObject!, game: Game)
    func gameTurnDone(sender: AnyObject!, game: Game)
}

class GameViewController: UIViewController, MakeGuessesDelegate, GiveCluesDelegate {

    var game: Game!
    var prevRound: Round!
    var currentRound: Round!
    var delegate: GameDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(game.currentPlayer.objectId == PFUser.currentUser().objectId, "logged in user must be the current player")

        let query = Round.query()
        query.whereKey("game", equalTo: game)
        if game.currentRoundIndex == 0 {
            query.whereKey("index", equalTo: game.currentRoundIndex)
            query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
                if error == nil {
                    self.currentRound = object as Round
                    if self.currentRound.wereCluesGiven() {
                        self.showMakeGuessesView()
                    } else {
                        self.showGiveCluesView()
                    }
                }
            }
        } else {
            query.whereKey("index", containedIn: [game.currentRoundIndex - 1, game.currentRoundIndex])
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil {
                    assert(objects.count == 2, "must have fetched two round objects")

                    let rounds = objects as [Round]
                    for round in rounds {
                        if round.index == self.game.currentRoundIndex {
                            self.currentRound = round
                        } else {
                            self.prevRound = round
                        }
                    }

                    if self.currentRound.wereCluesGiven() {
                        if self.prevRound.replayed.boolValue {
                            self.showMakeGuessesView()
                        } else {
                            //                            self.performSegueWithIdentifier("ShowReplayGuessesView", sender: self)
                        }
                    } else {
                        assert(!self.prevRound.replayed.boolValue, "previous round must not have been replayed if clues need to be given")
                        self.showGiveCluesView()
                    }
                }
            })
        }
    }

    func showMakeGuessesView() {
        let vc = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("MakeGuessesViewController") as MakeGuessesViewController
        vc.game = game
        vc.round = currentRound
        vc.delegate = self
        addChildViewController(vc)
        view.addSubview(vc.view)
        vc.didMoveToParentViewController(self)
    }

    func showGiveCluesView() {
        let vc = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("GiveCluesViewController") as GiveCluesViewController
        vc.game = game
        vc.round = currentRound
        vc.delegate = self
        addChildViewController(vc)
        view.addSubview(vc.view)
        vc.didMoveToParentViewController(self)
    }

    func removeChildViewControllers() {
        for vc in childViewControllers {
            vc.willMoveToParentViewController(nil)
            vc.view??.removeFromSuperview()
            vc.removeFromParentViewController()
        }
    }

    // MARK: MakeGuessesDelegate

    func makeGuessesCancelled(sender: AnyObject!) {
        delegate?.gameTurnCancelled(self, game: game)
    }

    func makeGuessesDone(sender: AnyObject!) {
        removeChildViewControllers()
        Round.newRoundInGame(game, index: currentRound.index + 1) { (newRound) -> Void in
            self.prevRound = self.currentRound
            self.currentRound = newRound
            self.game.currentRoundIndex += 1
            self.game.saveInBackgroundWithTarget(nil, selector: nil)
            self.showGiveCluesView()
        }
    }

    // MARK: GiveCluesDelegate

    func giveCluesCancelled(sender: AnyObject!) {
        delegate?.gameTurnCancelled(self, game: game)
    }

    func giveCluesDone(sender: AnyObject!) {
        delegate?.gameTurnDone(self, game: game)
    }
}
