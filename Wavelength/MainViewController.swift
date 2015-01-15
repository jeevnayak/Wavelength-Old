//
//  MainViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GameDelegate, MenuDelegate, FBFriendPickerDelegate {

    @IBOutlet weak var gamesCollectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var actionableGames: [Game]!
    var waitingGames: [Game]!
    var partnerFbIds: [String]!

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        gamesCollectionView.dataSource = self
        gamesCollectionView.delegate = self

        reloadGames()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowGameView" {
            let vc = segue.destinationViewController as GameViewController
            let selectedIndexPaths = gamesCollectionView.indexPathsForSelectedItems()
            assert(selectedIndexPaths.count == 1, "must have selected exactly one game")
            let selectedIndexPath = selectedIndexPaths[0] as NSIndexPath
            assert(selectedIndexPath.section == 0, "should only be able to select actionable games")
            vc.game = actionableGames[selectedIndexPath.row]
            vc.delegate = self
        } else if segue.identifier == "PresentMenuView" {
            let vc = segue.destinationViewController as MenuViewController
            vc.delegate = self
        } else if segue.identifier == "PresentNewGameView" || segue.identifier == "PresentNewGameViewFromCell" {
            let vc = segue.destinationViewController as NewGameViewController
            vc.delegate = self
        }
    }

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if waitingGames != nil && !waitingGames.isEmpty {
            return 2
        } else if actionableGames != nil {
            return 1
        } else {
            return 0
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            // if there are no actionable games, there should still be one item for the create new game cell
            return max(actionableGames.count, 1)
        } else {
            return waitingGames.count
        }
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        assert(kind == UICollectionElementKindSectionHeader, "all supplementary views should be headers")

        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "GameListHeaderView", forIndexPath: indexPath) as GameListHeaderView
        if indexPath.section == 0 {
            headerView.turnLabel.text = "YOUR TURN"
            headerView.currentStreakLabel.hidden = actionableGames.isEmpty
            headerView.levelLabel.hidden = actionableGames.isEmpty
        } else {
            headerView.turnLabel.text = "THEIR TURN"
            headerView.currentStreakLabel.hidden = false
            headerView.levelLabel.hidden = false
        }

        return headerView
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if isNewGameCellAtIndexPath(indexPath) {
            assert(indexPath.row == 0, "the create new game cell should always be the first and only item")
            return collectionView.dequeueReusableCellWithReuseIdentifier("NewGameCell", forIndexPath: indexPath) as NewGameCell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GameCell", forIndexPath: indexPath) as GameCell

            var game: Game
            if indexPath.section == 0 {
                game = actionableGames[indexPath.row]
            } else {
                game = waitingGames[indexPath.row]
            }
            cell.game = game

            return cell
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 24)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var height = CGFloat(61)
        if indexPath.row == collectionView.numberOfItemsInSection(indexPath.section) - 1 {
            // last item in the section shouldn't have a bottom divider
            height = CGFloat(60)
        }
        return CGSize(width: collectionView.bounds.size.width, height: height)
    }

    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (indexPath.section == 0)
    }

    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        if isNewGameCellAtIndexPath(indexPath) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as NewGameCell
            cell.highlight()
        } else {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as GameCell
            cell.highlight()
        }
    }

    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        if isNewGameCellAtIndexPath(indexPath) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as NewGameCell
            cell.unhighlight()
        } else {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as GameCell
            cell.unhighlight()
        }
    }

    // MARK: GameDelegate

    func gameTurnCancelled(sender: AnyObject!, game: Game) {
        dismissViewControllerAnimated(true, completion: nil)

        gamesCollectionView.reloadData()
    }

    func gameTurnDone(sender: AnyObject!, game: Game) {
        dismissViewControllerAnimated(true, completion: nil)

        assert(game.currentPlayer.objectId != PFUser.currentUser().objectId, "shouldn't be the current player's turn anymore")
        actionableGames = actionableGames.filter({ $0.objectId != game.objectId })
        waitingGames.append(game)
        gamesCollectionView.reloadData()
    }

    // MARK: MenuDelegate

    func menuBackButtonTap(sender: AnyObject!) {
        dismissViewControllerAnimated(true, completion: nil)
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
                game.player1FirstName = game.player1.objectForKey("firstName") as String
                game.player1Name = game.player1.objectForKey("name") as String
                game.player1FbId = game.player1.objectForKey("fbId") as String
                game.player2 = object as PFUser
                game.player2FirstName = game.player2.objectForKey("firstName") as String
                game.player2Name = game.player2.objectForKey("name") as String
                game.player2FbId = game.player2.objectForKey("fbId") as String
                game.currentRoundIndex = 0
                game.currentPlayer = PFUser.currentUser()
                game.currentStreak = 0
                game.words = []
                // TODO(rajeev): modifying the round and game together should be atomic
                game.saveInBackgroundWithBlock { (succeeded, error) -> Void in
                    if error == nil {
                        Round.newRoundInGame(game, index: 0, block: { (newRound, error) -> Void in
                            if error == nil {
                                self.actionableGames.append(game)
                                self.partnerFbIds.append(game.getPartnerFbId(PFUser.currentUser()))
                                self.gamesCollectionView.reloadData()
                                self.dismissViewControllerAnimated(true, completion: nil)
                            } else {
                                Helpers.showNetworkErrorDialogFromViewController(self)
                            }
                        })
                    } else {
                        Helpers.showNetworkErrorDialogFromViewController(self)
                    }
                }
            }
        }
    }

    func friendPickerViewController(friendPicker: FBFriendPickerViewController!, shouldIncludeUser user: FBGraphUser!) -> Bool {
        if let partnerFbIds = partnerFbIds {
            return !contains(partnerFbIds, user.objectID)
        } else {
            return true
        }
    }

    // MARK: event handlers

    func appDidBecomeActive(aNotification: NSNotification) {
        reloadGames()
    }

    // MARK: helpers

    func reloadGames() {
        loadingIndicator.startAnimating()
        Game.getGamesForUser(PFUser.currentUser(), block: { (actionableGames, waitingGames, error) -> Void in
            if error == nil {
                self.actionableGames = actionableGames
                self.waitingGames = waitingGames
                self.partnerFbIds = []
                for game in (actionableGames + waitingGames) {
                    self.partnerFbIds.append(game.getPartnerFbId(PFUser.currentUser()))
                }
                self.gamesCollectionView.reloadData()
            } else {
                Helpers.showNetworkErrorDialogFromViewController(self)
            }

            self.loadingIndicator.stopAnimating()
        })
    }

    func isNewGameCellAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 0 && actionableGames.isEmpty
    }
}
