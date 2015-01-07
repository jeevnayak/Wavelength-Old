//
//  Round.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/20/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class Round: PFObject, PFSubclassing {

    enum GuessState {
        case Empty
        case Pending
        case Incorrect
        case Correct
        case WavelengthPending
        case WavelengthIncorrect
        case WavelengthCorrect
    }

    enum GuessResult {
        case Empty
        case Incorrect
        case Correct
        case WavelengthIncorrect
        case WavelengthCorrect
    }

    @NSManaged var game: Game
    @NSManaged var index: Int
    @NSManaged var word: String
    @NSManaged var clues: NSArray
    @NSManaged var guesses: NSArray
    @NSManaged var replayed: NSNumber

    override class func load() {
        self.registerSubclass()
    }

    class func parseClassName() -> String! {
        return "Round"
    }

    class func newRoundInGame(game: Game, index: Int, block: (newRound: Round, error: NSError?) -> Void) {
        let round = Round()
        round.game = game
        round.index = index
        let words = ["COMPASS",
            "PLUM",
            "SEESAW",
            "COFFEE",
            "SKY",
            "SADDLE",
            "VIOLIN",
            "CIGAR",
            "SHADOW",
            "CACTUS",
            "HELICOPTER",
            "JEANS",
            "BASEBALL",
            "SMOKE",
            "MIME",
            "SNEAKERS",
            "SQUEAK",
            "SUBMARINE",
            "ANDROID",
            "HOODIE",
            "KEYBOARD",
            "ZIPPER",
            "CANADA",
            "LONDON",
            "HARRY POTTER",
            "GYM",
            "MICROWAVE",
            "REFRIGERATOR",
            "BEAN",
            "DOLLHOUSE",
            "PAWN",
            "ORIGAMI",
            "TOMATO",
            "SHARK",
            "POLE",
            "FROG",
            "WISDOM",
            "RAINCOAT",
            "SAUNA",
            "HERCULES",
            "PSYCHIC",
            "CHRISTMAS",
            "WINE",
            "TRUMP",
            "RECESS",
            "LEGO",
            "CRAYON",
            "TUXEDO",
            "VALENTINE",
            "SUBWAY",
            "CHAMPION",
            "BOLT",
            "TEXTBOOK",
            "CHEMISTRY",
            "DORITOS",
            "PILL",
            "LADY GAGA",
            "SWIFT",
            "UFO",
            "RAPUNZEL",
            "PENGUIN",
            "SNOOPY",
            "LAUGH",
            "COUNT",
            "POTATO",
            "CAVIAR",
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
            "FLY",
            "ONION",
            "GOLDFISH",
            "UMBRELLA",
            "POODLE",
            "BOTOX",
            "SESAME",
            "BUZZ",
            "BAGEL",
            "NUN",
            "RADIO",
            "BABY",
            "VALENTINE",
            "KINDLE",
            "MICHAEL JORDAN",
            "TICKET",
            "TREADMILL",
            "TOP",
            "GOOGLE",
            "SAFEWAY",
        ]
        let randomIndex = Int(arc4random_uniform(UInt32(words.count)))
        round.word = words[randomIndex]
        round.clues = []
        round.guesses = []
        round.replayed = NSNumber(bool: false)
        round.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            block(newRound: round, error: error)
        }
    }

    func wereCluesGiven() -> Bool {
        return clues.count > 0
    }

    func normalize(word: String) -> String {
        return word.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
    }

    func guessStates() -> [GuessState] {
        var states = [] as [GuessState]
        var correctGuessFound = false
        var emptyGuessFound = false
        for (i, clue) in enumerate(clues) {
            if guesses.count < i + 1 {
                if !emptyGuessFound {
                    if !correctGuessFound {
                        states.append(GuessState.Pending)
                    } else {
                        states.append(GuessState.WavelengthPending)
                    }
                    emptyGuessFound = true
                } else {
                    states.append(GuessState.Empty)
                }
                continue
            }

            let guess = guesses[i] as String
            if !correctGuessFound {
                if normalize(guess) == normalize(word) {
                    states.append(GuessState.Correct)
                    correctGuessFound = true
                } else {
                    states.append(GuessState.Incorrect)
                }
            } else {
                if normalize(guess) == normalize(clue as String) {
                    states.append(GuessState.WavelengthCorrect)
                } else {
                    states.append(GuessState.WavelengthIncorrect)
                }
            }
        }

        return states
    }

    func submitGuess(guess: String) -> GuessResult {
        let normalizedGuess = normalize(guess)
        if normalizedGuess.isEmpty {
            return GuessResult.Empty
        }

        let index = guesses.count
        var result: GuessResult
        switch guessStates()[index] {
        case .Pending:
            if normalize(guess) == normalize(word) {
                result = GuessResult.Correct
            } else {
                result = GuessResult.Incorrect
            }
        case .WavelengthPending:
            if normalize(guess) == normalize(clues[index] as String) {
                result = GuessResult.WavelengthCorrect
            } else {
                result = GuessResult.WavelengthIncorrect
            }
        default:
            assertionFailure("invalid state for submitted guess \(index): \(guessStates()[index])")
        }

        var newGuesses = [] as [String]
        for g in guesses {
            newGuesses.append(g as String)
        }
        newGuesses.append(guess)
        guesses = newGuesses
        saveInBackgroundWithTarget(nil, selector: nil)

        return result
    }

    func wasWon() -> Bool {
        for guess in guesses {
            if normalize(guess as String) == normalize(word) {
                return true
            }
        }

        return false
    }
}
