//
//  GameOverScene.swift
//  SpriteKitSimpleGameTut
//
//  Created by User on 10/4/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene
{
    init(size: CGSize, bWon: Bool)
    {
        super.init(size: size)
        
        backgroundColor = SKColor.white
        
        let message = bWon ? "You Won!" : "You Lose..."
        
        //displays a label of text to the screen with Sprite Kit
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        //transitions to a new instance of the Game Scene after a duration
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run({
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition: reveal)
            })
        ]))
    }
    
    //when overriding an initializer on a scene, the 'required init(coder:)' initializer must be implemented also
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

