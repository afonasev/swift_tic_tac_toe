enum Mark {
    case X, O
}

struct Turn {
    let x: Int
    let y: Int
}

class Board {
    // TODO: add size parameter
    var cells: [[Mark?]] = [
        [nil, nil, nil],
        [nil, nil, nil],
        [nil, nil, nil],
    ]

    let lines = [
        // dia
        [[0, 0], [1, 1], [2, 2]],
        [[2, 0], [1, 1], [0, 2]],

        // verticals
        [[0, 0], [0, 1], [0, 2]],
        [[1, 0], [1, 1], [1, 2]],
        [[2, 0], [2, 1], [2, 2]],

        // horizontals
        [[0, 0], [1, 0], [2, 0]],
        [[0, 1], [1, 1], [2, 1]],
        [[0, 2], [1, 2], [2, 2]],
    ]

    func setMark(_ x: Int, _ y: Int, _ mark: Mark) {
        cells[y][x] = mark
    }

    func isEmpty(_ x: Int, _ y: Int) -> Bool {
        return cells[y][x] == nil
    }
}

class Game {
    let board: Board
    let ui: UserInterface

    init(board: Board, ui: UserInterface) {
        self.board = board
        self.ui = ui
    }

    func startGameLoop(firstPlayer: Mark) {
        var currentPlayer = firstPlayer

        while true {
            ui.displayBoard(board)

            let nextTurn = ui.getNextTurn(currentPlayer)
            if !isCorrectTurn(board, nextTurn) {
                ui.displayInvalidTurnMessage(nextTurn)
                continue
            }

            board.setMark(nextTurn.x, nextTurn.y, currentPlayer)

            if hasWinner(board) {
                ui.displayBoard(board)
                ui.displayWinnerMessage(currentPlayer)
                return
            } else if hasDraw(board) {
                ui.displayBoard(board)
                ui.displayDrawMessage()
                return
            }

            currentPlayer = getNextPlayer(currentPlayer)
        }
    }

    private func isCorrectTurn(_: Board, _ turn: Turn) -> Bool {
        if turn.x < 0 || turn.x > 2 || turn.y < 0 || turn.y > 2 {
            return false
        }

        return board.isEmpty(turn.x, turn.y)
    }

    private func getNextPlayer(_ lastPlayer: Mark) -> Mark {
        switch lastPlayer {
        case .X:
            return Mark.O
        default:
            return Mark.X
        }
    }

    private func hasWinner(_ board: Board) -> Bool {
        let cells = board.cells

        for line in board.lines {
            var mark: Mark?
            var hasWinner = true

            for cell in line {
                let x = cell[0]
                let y = cell[1]
                let currentMark = cells[x][y]

                if cells[x][y] == nil {
                    hasWinner = false
                    break
                } else if mark == nil {
                    mark = currentMark
                } else if currentMark != mark {
                    hasWinner = false
                    break
                }
            }

            if hasWinner {
                return true
            }
        }

        return false
    }

    private func hasDraw(_ board: Board) -> Bool {
        for line in board.cells {
            for cell in line {
                if cell == nil {
                    return false
                }
            }
        }

        return true
    }
}

protocol UserInterface {
    func displayBoard(_ board: Board)
    func getNextTurn(_ currentPlayer: Mark) -> Turn
    func displayWinnerMessage(_ winnerPlayer: Mark)
    func displayDrawMessage()
    func displayInvalidTurnMessage(_ turn: Turn)
}

class ConsoleInterface: UserInterface {
    func displayBoard(_ board: Board) {
        print()

        for line in board.cells {
            for symbol in line {
                if symbol == nil {
                    print("_ ", terminator: "")
                } else {
                    print("\(symbol!) ", terminator: "")
                }
            }
            print()
        }
    }

    func getNextTurn(_ currentPlayer: Mark) -> Turn {
        print("Current player: \(currentPlayer)")
        while true {
            print("Enter your next turn ('x y') :")

            let rawInput = readLine()

            if rawInput != nil {
                let nextTurn = parseTurn(rawInput!)

                if nextTurn != nil {
                    return nextTurn!
                }
            }

            print("\(rawInput ?? ""): invalid input")
        }
    }

    private func parseTurn(_ rawInput: String) -> Turn? {
        let symbols = rawInput.split(separator: " ")

        if symbols.count != 2 {
            return nil
        }

        let rawX = Int(symbols[0])
        let rawY = Int(symbols[1])

        if let x = rawX, let y = rawY {
            return Turn(x: x, y: y)
        }

        return nil
    }

    func displayWinnerMessage(_ winnerPlayer: Mark) {
        print("Winner: '\(winnerPlayer)'")
    }

    func displayDrawMessage() {
        print("Draw")
    }

    func displayInvalidTurnMessage(_ turn: Turn) {
        print("\(turn): invalid turn")
    }
}

let game = Game(board: Board(), ui: ConsoleInterface())
game.startGameLoop(firstPlayer: Mark.X)
