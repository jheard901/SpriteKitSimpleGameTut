//
//  GameScene.swift
//  SpriteKitSimpleGameTut
//
//  Created by User on 10/4/16.
//  Copyright © 2016 User. All rights reserved.
//

import SpriteKit
import GameplayKit

//these are custom defined math functions that will be used in creating this game
//operator overloading in Swift
func + (left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar:CGFloat) -> CGPoint
{
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar:CGFloat) -> CGPoint
{
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat
{
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint
{
    func length() -> CGFloat
    {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint
    {
        return self / length()
    }
}

struct PhysicsCategory
{
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Character : UInt32 = 0b1 //1 //this is for categorizing physics bodies
    static let Projectile : UInt32 = 0b10  //2
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var monstersDestroyed = 0
    
    let player = SKSpriteNode(imageNamed:"TutResources/sprites.atlas/player.png")
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.white
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(player)
        
        //sets physicsWorld to have no gravity and sets the scene (self) as the delegate to be notified when two physics bodies collide
        physicsWorld.gravity = CGVector.init(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        //when running a block you need to include curly braces for the block as mentioned here: http://stackoverflow.com/questions/26411883/swift-skaction-runblock-missing-argument-for-parameter-completion-in-call
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run({self.addMonster()}),
            SKAction.wait(forDuration: 1.0)])
        ))
        SKAction.run(addMonster)
        
        //add some background music to scene
        let bgMusic = SKAudioNode(fileNamed: "TutResources/Sounds/background-music-aac.caf")
        bgMusic.autoplayLooped = true
        addChild(bgMusic)
    }
    
    //brief observation for swift: func means its a function, the function name follows, optional to stick in parameters as param name then typename, and the -> arrow means it returns whatever type is specified next to it, then the { } braces are used
    func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) ->CGFloat
    {
        return random() * (max - min) + min
    }
    
    func addMonster()
    {
        //create sprite
        let monster = SKSpriteNode(imageNamed: "TutResources/sprites.atlas/monster.png")
        
        //determine where to spawn monster along Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        //position monster slightly off screen along the right edge
        //and at the random Y position 'actualY'
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        //add the monster to the scene
        addChild(monster)
        
        //set up physics of monster
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true   //Dynamic means the spire is controlled only through code
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Character    //the category used by this object
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile    //the categories of objects this object should notify the category listener when they intersect
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None    //the categories of objects that the physics engine handles contact responses to for this object (i.e. bounces off)
        
        //represents speed of monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        //create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()    //this effectively deletes a node from the scene
        //displays the game over scene when a monster goes off screen
        let loseAction = SKAction.run({
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, bWon: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        })
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))    //note, actionMoveDone isn't needed anymore since nodes are automatically removed when a scene transitions to a new one
        
        
    }
    
    //removes the monster and projectile from the scene
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode)
    {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed += 1
        if(monstersDestroyed > 15)
        {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, bWon:true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    //since the scene is set as the contact delegate, then it will call this function each time a valid collision occurs
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        //since this method doesn't guarantee that two bodies that collide are passed in a particular order, then we use this code to arrange them by their category bit mask allowing us to make assumption on this later
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //checks that the two bodies colliding are a Projectile and Character
        if((firstBody.categoryBitMask & PhysicsCategory.Character != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0))
        {
            projectileDidCollideWithMonster(projectile: firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //choose one of the touches to work with
        guard let touch = touches.first else
        {
            return
        }
        let touchLocation = touch.location(in: self)
        
        //set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "TutResources/sprites.atlas/projectile.png")
        projectile.position = player.position
        
        //set up physics of projectile
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Character
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true    //this is usually on for fast moving objects which can sometimes miss collision detection due to the object moving too fast
        
        
        //determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        //bail out if you are shooting down or backwards
        if(offset.x < 0) { return }
        
        //play a sound effect for the projectile
        run(SKAction.playSoundFileNamed("TutResources/Sounds/pew-pew-lei.caf", waitForCompletion: false))
        
        //ok to add projectile since checking the touch position
        addChild(projectile)
        
        //get direction of where to shoot
        let direction = offset.normalized()
        
        //make it shoot far enough to be guaranteed offscreen
        let shootAmount = direction * 1000.0
        
        //add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        //create the actions
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    
    
    
    
    /*
    //for some reason you can't fold comment in Swift but you can with Objective C as stated here:
    //http://stackoverflow.com/questions/32573269/how-can-i-fold-blocks-of-comments-in-swift-using-xcode-the-way-i-do-it-in-visual
     
    //This explains why autocomplete for filenames of images pop up as tiny little boxes (got to scroll down a bit or cmd+F search for "literals". Essentially they are called literals and imo should be a feature that can be turned off because they do NOT work as stated they should, and it's a pain in the bum to see that pop up while typing a filename:
     //https://developer.apple.com/swift/blog/
    
     
    
    ////// This stuff below was already here! //////
     
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
    
    */
    
    
}
