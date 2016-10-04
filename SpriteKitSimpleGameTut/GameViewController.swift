//
//  GameViewController.swift
//  SpriteKitSimpleGameTut
//
//  Created by User on 10/4/16.
//  Copyright © 2016 User. All rights reserved.
//

//creating a game based off the following tut: https://www.raywenderlich.com/119815/sprite-kit-swift-2-tutorial-for-beginners


/*
Some extra exercises you could do with this are:
 
-Add a label in the game scene to display how many monsters the player has destroyed
 OR
-Make a label that displays the remaining number of monsters the player needs to kill
-Create a menu transitioning interface from a Main Menu to the Game scene
-Create levels that are transitioned to once the player has won in a scene
-Create a life system for the player (eg 3 lives); lose 1 life each time a monster makes it to end
-Create movement system for the player character; limit it to just being vertical movement to allow different origin points for projectiles 
*/

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
