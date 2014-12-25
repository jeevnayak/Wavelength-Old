//
//  Round.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class Round: PFObject, PFSubclassing {

    @NSManaged var game: Game
    @NSManaged var index: Int
    @NSManaged var word: String
    @NSManaged var clues: NSArray
    @NSManaged var guesses: NSArray
    @NSManaged var correctGuess: Int
    @NSManaged var replayed: NSNumber

    override class func load() {
        self.registerSubclass()
    }

    class func parseClassName() -> String! {
        return "Round"
    }

    class func newRoundInGame(game: Game, index: Int, block: (newRound: Round) -> Void) {
        let round = Round()
        round.game = game
        round.index = index
        let words = ["COMPASS",
            "PLUM",
            "SEESAW",
            "RAPUNZEL",
            "PENGUIN",
            "SADDLE",
            "SNOOPY",
            "CIGAR",
            "SHADOW",
            "CACTUS",
            "LAUGH",
            "COUNT",
            "POTATO",
            "SMOKE",
            "MIME",
            "CAVIAR",
            "SQUEAK",
            "SUBMARINE",
            "MYTH",
            "COCKROACH",
            "TICKLE",
            "WHISKERS",
            "ROBIN",
            "LAS VEGAS",
            "MOUTHWASH",
            "PENTAGON",
            "OVEN",
            "MAYFLOWER",
            "CUDDLE",
            "DOLLHOUSE",
            "PAWN",
            "FLY",
            "ONION",
            "GOLDFISH",
            "UMBRELLA",
            "POODLE",
            "BOTOX",
            "RAINCOAT",
            "SAUNA",
            "HERCULES",
            "PSYCHIC",
            "SESAME",
            "BUZZ",
            "TRUMP",
            "BAGEL",
            "NUN",
            "RADIO",
            "BABY",
            "VALENTINE"
        ]
        let randomIndex = Int(arc4random_uniform(UInt32(words.count)))
        round.word = words[randomIndex]
        round.clues = []
        round.guesses = []
        round.correctGuess = -1
        round.replayed = NSNumber(bool: false)
        round.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            if error == nil {
                block(newRound: round)
            }
        }
    }

    func wereCluesGiven() -> Bool {
        return clues.count > 0
    }
}
