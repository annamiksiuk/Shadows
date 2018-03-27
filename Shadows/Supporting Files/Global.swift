//
//  Global.swift
//  Shadows
//
//  Created by Anna Miksiuk on 21.03.2018.
//  Copyright © 2018 Anna Miksiuk. All rights reserved.
//

import UIKit

let pages = ["BlueSky", "Winter", "Sea", "Fields", "Arctic"]

let elements = ["Sun", "Rainbow", "Fish", "Panda", "Monkey", "Snail", "Pig", "Rodent", "Racoon", "Rabbit", "Parrot",
                "Owl", "Octopus", "Leopard", "Chicken", "Turtle", "Walrus", "Hippo", "Snowman", "Alligator", "Bear", "Bird",
                "Cat", "Deer", "Elephant", "Giraffe", "Goose", "Duck", "Hedgehog", "Butterfly", "Flower", "Lion"]

let failSounds = ["Angry", "Back", "Fly"]
let successSound = "Find"
let emptySound = "Not"
let browseSound = "Click"

let widthElement : CGFloat = 80
let heightElement : CGFloat = 90

func randomInt(to: Int) -> Int {
  return randomInt(from: 0, to: to)
}

func randomInt(from: Int, to: Int) -> Int {
  return Int(arc4random_uniform(UInt32(to - from))) + from
}
