//
//  MainViewController.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class MainViewController: UIViewController {

    var actionableGames: [Game]!
    var waitingGames: [Game]!
    var opponentFbIds: [String]!

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

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
        })
    }

    @IBAction func onLogoutButtonTap(sender: AnyObject) {
        PFUser.logOut()

        let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController
        let loginVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginViewController") as? UIViewController
        UIView.transitionFromView(rootVC!.view, toView: loginVC!.view, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: { (finished) -> Void in
            let appDelegate = UIApplication.sharedApplication().delegate
            appDelegate?.window??.rootViewController = loginVC
        })
    }
}
