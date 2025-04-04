//
//  main.swift
//  Mouse&Cheese
//
//  Created by Chernokoz on 04.04.2025.
//

import Foundation

struct Character {
    var position: (Int, Int)
}

struct Room {
    var height: Int
    var width: Int
    
    func printRoom(chief: Character, mouse: Character, cheese: Cheese) {
        print("\n")
        for i in 0..<height {
            var row: String = ""
            for j in 0..<width {
                if chief.position == (j, i) {
                    row.append("👨‍🍳")
                } else if mouse.position == (j, i) {
                    row.append("🐭")
                } else if cheese.position == (j, i) {
                    row.append("🧀")
                } else {
                    row.append("⬜️")
                }
            }
            print(row)
        }
    }
}

struct Cheese {
    var position: (Int, Int)
    
    mutating func randomCheesePosition(room: Room) -> (Int, Int) {
        let x: Int = Int.random(in: 0..<room.width)
        let y: Int = Int.random(in: 0..<room.height)
        return (x, y)
    }
}

var chief: Character = Character(position: (3, 3))

var mouse: Character = Character(position: (5, 5))

var room: Room = Room(height: 8, width: 10)

var cheese = Cheese(position: (0, 0))
cheese.position = cheese.randomCheesePosition(room: room)

enum Run {
    case up
    case down
    case left
    case right
    
    func move(x: inout Int, y: inout Int) {
        switch self {
        case .up:
            y -= 1
        case .down:
            y += 1
        case .left:
            x -= 1
        case .right:
            x += 1
        }
    }
}

room.printRoom(chief: chief, mouse: mouse, cheese: cheese)

var player = readLine()

func getDirection(from input: String) -> Run? {
    switch input.lowercased() {
    case "w": return .up
    case "s": return .down
    case "a": return .left
    case "d": return .right
    default: return nil
    }
}

extension Character {
    mutating func move(_ direction: Run, in room: Room) {
        var newX = position.0
        var newY = position.1
        direction.move(x: &newX, y: &newY)
        
        // Проверка границ комнаты
        if newX >= 0 && newX < room.width && newY >= 0 && newY < room.height {
            position = (newX, newY)
        }
    }
}

extension Character {
    mutating func moveChief(towards target: Character, in room: Room) {
        let dx = target.position.0 - position.0
        let dy = target.position.1 - position.1
        
        if abs(dx) > abs(dy) {
            position.0 += dx > 0 ? 1 : -1
        } else {
            position.1 += dy > 0 ? 1 : -1
        }
        
        // Ограничение границ
        position.0 = max(0, min(position.0, room.width - 1))
        position.1 = max(0, min(position.1, room.height - 1))
    }
}

var score = 0
var gameOver = false

while !gameOver {
    // Очищаем консоль в начале каждого хода
    print("\u{001B}[2J")
    
    // Обновляем и отображаем игровое поле
    room.printRoom(chief: chief, mouse: mouse, cheese: cheese)
    print("Счет: \(score)")
    print("Введите направление (WASD):")
    
    // Ждем ввод пользователя
    guard let input = readLine(), let direction = getDirection(from: input) else {
        print("Некорректный ввод. Используйте WASD для движения.")
        continue
    }
    
    // Движение мыши
    mouse.move(direction, in: room)
    
    // Проверка на сбор сыра
    if mouse.position == cheese.position {
        score += 1
        cheese.position = cheese.randomCheesePosition(room: room)
        // Убедимся, что сыр не появляется на поваре
        while cheese.position == chief.position {
            cheese.position = cheese.randomCheesePosition(room: room)
        }
    }
    
    // Движение повара (простой ИИ)
    chief.moveChief(towards: mouse, in: room)
    
    // Проверка на проигрыш
    if chief.position == mouse.position {
        gameOver = true
        print("\u{001B}[2J") // Очищаем консоль перед выводом итогов
        room.printRoom(chief: chief, mouse: mouse, cheese: cheese)
        print("Игра окончена! Ваш счет: \(score)")
    }
    
    // Небольшая задержка для удобства восприятия
    usleep(300_000)
}

while cheese.position == chief.position {
    cheese.position = cheese.randomCheesePosition(room: room)
}

print("\n  Счет: \(score)")
print("  Введите направление (WASD):", terminator: " ")


//print("👨‍🍳🐀🐭🍅🧅🧄🧀🥐🫑🥕")

