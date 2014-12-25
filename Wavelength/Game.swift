//
//  Game.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class Game: PFObject, PFSubclassing {

    @NSManaged var player1: PFUser
    @NSManaged var player1FirstName: String
    @NSManaged var player1Name: String
    @NSManaged var player1FbId: String
    @NSManaged var player2: PFUser
    @NSManaged var player2FirstName: String
    @NSManaged var player2Name: String
    @NSManaged var player2FbId: String
    @NSManaged var currentRoundIndex: Int
    @NSManaged var currentPlayer: PFUser

    override class func load() {
        self.registerSubclass()
    }

    class func parseClassName() -> String! {
        return "Game"
    }

    class func getGamesForUser(user: PFUser, block: (actionableGames: [Game], waitingGames: [Game]) -> Void) {
        let query = Game.query()
        query.whereKey("player1", equalTo: user)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let query2 = Game.query()
                query2.whereKey("player2", equalTo: user)
                query2.findObjectsInBackgroundWithBlock({ (objects2, error2) -> Void in
                    if error2 == nil {
                        var actionableGames: [Game] = []
                        var waitingGames: [Game] = []
                        for game in ((objects + objects2) as [Game]) {
                            if game.currentPlayer.objectId == PFUser.currentUser().objectId {
                                actionableGames.append(game)
                            } else {
                                waitingGames.append(game)
                            }
                        }
                        block(actionableGames: actionableGames, waitingGames: waitingGames)
                    }
                })
            }
        }
    }

    func getPartner(player: PFUser) -> PFUser {
        if player.objectId == player1.objectId {
            return player2
        } else {
            return player1
        }
    }

    func getPartnerFbId(player: PFUser) -> String {
        if player.objectId == player1.objectId {
            return player2FbId
        } else {
            return player1FbId
        }
    }

    func getPartnerFirstName(player: PFUser) -> String {
        if player.objectId == player1.objectId {
            return player2FirstName
        } else {
            return player1FirstName
        }
    }
}
