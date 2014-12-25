//
//  LoadGameViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/24/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class LoadGameViewController: UIViewController {

    var game: Game!
    var prevRound: Round!
    var currentRound: Round!

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
//                        self.performSegueWithIdentifier("ShowMakeGuessesView", sender: self)
                    } else {
                        self.performSegueWithIdentifier("ShowGiveCluesView", sender: self)
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
//                            self.performSegueWithIdentifier("ShowMakeGuessesView", sender: self)
                        } else {
//                            self.performSegueWithIdentifier("ShowReplayGuessesView", sender: self)
                        }
                    } else {
                        assert(!self.prevRound.replayed.boolValue, "previous round must not have been replayed if clues need to be given")
                        self.performSegueWithIdentifier("ShowGiveCluesView", sender: self)
                    }
                }
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowGiveCluesView" {
            let vc = segue.destinationViewController as GiveCluesViewController
            vc.game = game
            vc.round = currentRound
        }
    }
}
