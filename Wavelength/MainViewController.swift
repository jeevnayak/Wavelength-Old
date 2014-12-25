//
//  MainViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GameDelegate, MenuDelegate, FBFriendPickerDelegate {

    @IBOutlet weak var gamesCollectionView: UICollectionView!

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
        } else if segue.identifier == "PresentNewGameView" {
            let vc = segue.destinationViewController as NewGameViewController
            vc.delegate = self
        }
    }

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let waitingGames = waitingGames {
            if waitingGames.count > 0 {
                return 2
            }
        }

        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection(section)
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        assert(kind == UICollectionElementKindSectionHeader, "all supplementary views should be headers")

        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "GameListHeaderView", forIndexPath: indexPath) as GameListHeaderView
        if indexPath.section == 0 {
            headerView.turnLabel.text = "YOUR TURN"
            headerView.currentStreakLabel.hidden = (actionableGames == nil) || (actionableGames.count == 0)
            headerView.levelLabel.hidden = (actionableGames == nil) || (actionableGames.count == 0)
        } else {
            headerView.turnLabel.text = "THEIR TURN"
            headerView.currentStreakLabel.hidden = false
            headerView.levelLabel.hidden = false
        }

        return headerView
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 24)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var height = CGFloat(61)
        if indexPath.row == numberOfItemsInSection(indexPath.section) - 1 {
            // last item in the section shouldn't have a bottom divider
            height = CGFloat(60)
        }
        return CGSize(width: collectionView.bounds.size.width, height: height)
    }

    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (indexPath.section == 0)
    }

    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as GameCell
        cell.highlight()
    }

    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as GameCell
        cell.unhighlight()
    }

    // MARK: GameDelegate

    func gameTurnCancelled(sender: AnyObject!, game: Game) {
        dismissViewControllerAnimated(true, completion: nil)
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
        if let partnerFbIds = partnerFbIds {
            return !contains(partnerFbIds, user.objectID)
        } else {
            return true
        }
    }

    // MARK: helpers

    func reloadGames() {
        Game.getGamesForUser(PFUser.currentUser(), block: { (actionableGames, waitingGames) -> Void in
            self.actionableGames = actionableGames
            self.waitingGames = waitingGames
            self.partnerFbIds = []
            for game in (actionableGames + waitingGames) {
                self.partnerFbIds.append(game.getPartnerFbId(PFUser.currentUser()))
            }
            self.gamesCollectionView.reloadData()
        })
    }

    func numberOfItemsInSection(section: Int) -> Int {
        if section == 0 {
            if let games = actionableGames {
                return games.count
            } else {
                return 0
            }
        } else {
            return waitingGames.count
        }
    }
}
