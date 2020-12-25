//
//  ViewController.swift
//  PokerOdds
//
//  Created by Haiming Xu on 12/24/20.
//

import UIKit

class ViewController: UIViewController {

    struct Hole {
        var card1: Int
        var card2: Int
        var suite1: String
        var suite2: String
        
        func values() -> [Int] {
            let suiteDict = ["spades" : 1, "clubs" : 2, "diamonds" : 3, "hearts" : 4]
            return [card1 * suiteDict[suite1]!, card2 * suiteDict[suite2]!]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let calculate = UIButton(type: .system)
        calculate.frame = CGRect(
            x: self.view.frame.origin.x ,
            y: self.view.frame.origin.y + UIScreen.main.bounds.size.height * 0.5,
            width: 100,
            height: 50
        )
        calculate.setTitle("Tap me", for: .normal)
        calculate.backgroundColor = .black
        calculate.addTarget(self, action: #selector(start(_:)), for: .touchUpInside)
        self.view.addSubview(calculate)
    }
    
    func getCardValue(card: Int, suite: String) -> Int {
        let suiteDict = ["spades" : 1, "clubs" : 2, "diamonds" : 3, "hearts" : 4]
        return card * suiteDict[suite]!
    }
    
    func getCardDetails(card: Int) -> (Int, String) {
        var value = card % 13
        if value == 0 {
            value = 13
        }
        if card <= 13 {
            return (value, "spades")
        } else if card <= 26 {
            return (value, "clubs")
        } else if card <= 39 {
            return (value, "diamonds")
        }
        return (value, "hearts")
    }

    func setCard(player: inout Hole, first: Bool, seen: inout [Int]) {
        while true {
            let temp = Int.random(in: 1..<53)
            var breaker = false
            for s in seen {
                if s == temp {
                    breaker = true
                    break
                }
            }
            if breaker {
                continue
            }
            let vals = getCardDetails(card: temp)
            if first {
                player.card1 = vals.0
                player.suite1 = vals.1
            } else {
                player.card2 = vals.0
                player.suite2 = vals.1
            }
            seen.append(temp)
            break
        }
    }
    
    @objc func start(_ sender : UIButton!) {
        // temporary constants
        let players = 8
        let myHand = Hole(card1: 12, card2: 12, suite1: "diamonds", suite2: "clubs")
        var wins = 0
        let runs = 20000
        for _ in 1...runs {
            var seen = myHand.values()
            var otherHands: [Hole] = []
            var board: [Int] = []
            for _ in 1...players {
                var newPlayer = Hole(card1: 0, card2: 0, suite1: "", suite2: "")
                setCard(player: &newPlayer, first: true, seen: &seen)
                setCard(player: &newPlayer, first: false, seen: &seen)
                otherHands.append(newPlayer)
            }
            for _ in 1...5 {
                while true {
                    let temp = Int.random(in: 1..<53)
                    var breaker = false
                    for s in seen {
                        if s == temp {
                            breaker = true
                            break
                        }
                    }
                    if breaker {
                        continue
                    }
                    seen.append(temp)
                    board.append(temp)
                    break
                }
            }
            let myValue = findValue(hole: myHand, board: board)
            var breaker = false
            for hand in otherHands {
                let compare = findValue(hole: hand, board: board)
                if compare > myValue {
                    breaker = true
                    break
                }
            }
            if !breaker {
                wins += 1
            }
        }
        print(wins)
        print(Float(wins) / Float(runs))
    }
    
    func findValue(hole: Hole, board: [Int]) -> Int {
        if royalFlush(hole: hole, board: board) {
            return 100000
        }
        if straightFlush(hole: hole, board: board).0 {
            return 90000 + straightFlush(hole: hole, board: board).1
        }
        if quads(hole: hole, board: board).0 {
            return 80000 + quads(hole: hole, board: board).1
        }
        if fullHouse(hole: hole, board: board).0 {
            return 70000 + fullHouse(hole: hole, board: board).1 * 100 + fullHouse(hole: hole, board: board).2
        }
        if flush(hole: hole, board: board).0 {
            return 60000 + flush(hole: hole, board: board).1
        }
        if straight(hole: hole, board: board).0 {
            return 50000 + straight(hole: hole, board: board).1
        }
        if trips(hole: hole, board: board).0 {
            return 40000 + trips(hole: hole, board: board).1
        }
        if twoPair(hole: hole, board: board).0 {
            return 30000 + twoPair(hole: hole, board: board).1 * 100 + twoPair(hole: hole, board: board).2
        }
        if pair(hole: hole, board: board).0 {
            return 20000 + pair(hole: hole, board: board).1
        }
        return 10000 + high(h: hole, board: board)
    }
    
    func getSevenCards(hole: Hole, board: [Int]) -> [Int] {
        var copy = board
        copy.append(getCardValue(card: hole.card1, suite: hole.suite1))
        copy.append(getCardValue(card: hole.card2, suite: hole.suite2))
        return copy
    }
    
    func royalFlush(hole: Hole, board: [Int]) -> Bool {
        let total: Set = Set(getSevenCards(hole: hole, board: board))
        let testSuite = [9, 22, 35, 48]
        for i in testSuite {
            var breaker = false
            for counter in 0...4 {
                if !total.contains(i + counter) {
                    breaker = true
                    break
                }
            }
            if !breaker {
                return true
            }
        }
        return false
    }
    
    func straightFlush(hole: Hole, board: [Int]) -> (Bool, Int) {
        let total: Set = Set(getSevenCards(hole: hole, board: board))
        for i in (1...52).reversed() {
            var breaker = false
            if i % 13 >= 9 || i % 13 == 0 {
                continue
            }
            for counter in 0...4 {
                if !total.contains(i + counter) {
                    breaker = true
                    break
                }
            }
            if !breaker {
                return (true, i + 4)
            }
        }
        return (false, 0)
    }
    
    func quads(hole: Hole, board: [Int]) -> (Bool, Int) {
        let total: Set = Set(getSevenCards(hole: hole, board: board))
        for i in 1...13 {
            var breaker = false
            for counter in 0...3 {
                if !total.contains(i + counter * 13) {
                    breaker = true
                    break
                }
            }
            if !breaker {
                return (true, i)
            }
        }
        return (false, 0)
    }
    
    func fullHouse(hole: Hole, board: [Int]) -> (Bool, Int, Int) {
        let total: Set = Set(getSevenCards(hole: hole, board: board))
        for i in (1...13).reversed() {
            var counter = 0
            for j in 0...3 {
                if total.contains(i + j * 13) {
                    counter += 1
                }
            }
            if counter == 3 {
                for j in (1...13).reversed() {
                    var counter2 = 0
                    if j == i {
                        continue
                    }
                    for k in 0...3 {
                        if total.contains(j + k * 13) {
                            counter2 += 1
                        }
                    }
                    if counter2 == 2 {
                        return (true, i, j)
                    }
                }
            }
        }
        return (false, 0, 0)
    }
    
    func flush(hole: Hole, board: [Int]) -> (Bool, Int) {
        let total: Set = Set(getSevenCards(hole: hole, board: board))
        for i in (0...3).reversed() {
            var counter = 0
            var biggest = 0
            for j in total {
                if j > i * 13 && j <= (i + 1) * 13 {
                    counter += 1
                    biggest = max(biggest, j % 13 == 0 ? 13 : j % 13)
                }
            }
            if counter >= 5 {
                return (true, biggest + 13 * i)
            }
        }
        return (false, 0)
    }
    
    func straight(hole: Hole, board: [Int]) -> (Bool, Int) {
        let total: Set = Set(getSevenCards(hole: hole, board: board))
        for i in (1...13).reversed() {
            var breaker = false
            if i % 13 > 9 {
                continue
            }
            let j = i < 13 ? i : 0
            for counter in 0...4 {
                if !total.contains(j + counter) && !total.contains(j + counter + 13)
                    && !total.contains(j + counter + 26) && !total.contains(j + counter + 39) {
                    breaker = true
                    break
                }
            }
            if !breaker {
                return (true, j + 4)
            }
        }
        return (false, 0)
    }
    
    func trips(hole: Hole, board: [Int]) -> (Bool, Int) {
        let total: Set = Set(getSevenCards(hole: hole, board: board))
        for i in (1...13).reversed() {
            var counter = 0
            for j in 0...3 {
                if total.contains(i + j * 13) {
                    counter += 1
                }
            }
            if counter == 3 {
                return (true, i)
            }
        }
        return (false, 0)
    }
    
    func twoPair(hole: Hole, board: [Int]) -> (Bool, Int, Int) {
        let total: Set = Set(getSevenCards(hole: hole, board: board))
        for i in (1...13).reversed() {
            var counter = 0
            for j in 0...3 {
                if total.contains(i + j * 13) {
                    counter += 1
                }
            }
            if counter == 2 {
                for j in (1...13).reversed() {
                    var counter2 = 0
                    if j == i {
                        continue
                    }
                    for k in 0...3 {
                        if total.contains(j + k * 13) {
                            counter2 += 1
                        }
                    }
                    if counter2 == 2 {
                        return (true, max(i, j), min(i, j))
                    }
                }
            }
        }
        return (false, 0, 0)
    }
    
    func pair(hole: Hole, board: [Int]) -> (Bool, Int) {
        let total: Set = Set(getSevenCards(hole: hole, board: board))
        for i in (1...13).reversed() {
            var counter = 0
            for j in 0...3 {
                if total.contains(i + j * 13) {
                    counter += 1
                }
            }
            if counter == 2 {
                return (true, i)
            }
        }
        return (false, 0)
    }
    
    func high(h: Hole, board: [Int]) -> Int {
        var t = [h.card1 % 13 == 0 ? 13 : h.card1 % 13, h.card2 % 13 == 0 ? 13 : h.card2 % 13]
        for i in board {
            t.append(i % 13 == 0 ? 13 : i % 13)
        }
        t.sort()
        return t[6]
    }
}

