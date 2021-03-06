//
//  GameScene.swift
//  FloppyFish
//
//  Created by Colin Morrison on 31/10/2021.
//

import SpriteKit
import GameplayKit

struct ColliderType {
    static let traveller: UInt32 = 0
    static let obstacle: UInt32 = 1
    static let minBoundary: UInt32 = 2
    static let maxBoundary: UInt32 = 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
            
    private(set) var obstacleCreator: ObstacleCreator!
    private(set) var backgroundHandler: BackgroundHandler?
    private(set) var worldPhysics: WorldPhysics!
    private(set) var travellerCreator: TravellerCreator?
    private(set) var gameEndedView: GameEndedView?
    
    private(set) var scoreHandler: ScoreHandler?
    private(set) var pauseButton: PauseButton?
    private(set) var countDownLabel: SKLabelNode?
    
    private(set) var countDownTimer: Timer?
    private(set) var obstacleTimer: Timer?
    private(set) var travellerRotatorTimer: Timer?
    private(set) var cleanupTimer: Timer?
    private(set) var scoreTimer: Timer?
    private(set) var timers: [Timer?]?
    
    private(set) var countDownTime = 3
                
    override func didMove(to view: SKView) {
        obstacleCreator = ObstacleCreator(delegate: self)
        worldPhysics = WorldPhysics(delegate: self)
        travellerCreator = TravellerCreator(delegate: self)
        
        self.scaleMode = .resizeFill
        setUpScene()
    }
    
    func setUpScene() {
        setUpBackground()
        setUpPauseButton()
        setUpScoreHandler()
        setUpWorld()
        setUpTraveller()
        setUpTimers()
    }
    
    func setUpBackground() {
        backgroundHandler = BackgroundHandler(delegate: self)
        backgroundHandler?.renderBackground()
    }
    
    func setUpPauseButton() {
        pauseButton = PauseButton(delegate: self)
        pauseButton?.hide()
    }
    
    func setUpScoreHandler() {
        scoreHandler = ScoreHandler(delegate: self)
        scoreHandler?.hide()
    }
    
    func setUpWorld() {
        worldPhysics.setUpPhysicsWorld()
        worldPhysics.addBoundaries()
    }
    
    func setUpTraveller() {
        travellerCreator?.setUpTraveller()
        travellerCreator?.pauseTraveller()
    }
    
    func hideGameplayNodes() {
        pauseButton?.hide()
        scoreHandler?.hide()
    }
    
    func showGameplayNodes() {
        pauseButton?.show()
        scoreHandler?.show()
    }
    
    func setUpTimers() {
        let timeInterval = TimeInterval(1.2)
                
        countDownTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.6), target: self, selector: #selector(GameScene.setUpCountdown), userInfo: nil, repeats: true)
        
        obstacleTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(GameScene.handleObstacleTimer), userInfo:nil, repeats: true)
        
        travellerRotatorTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(GameScene.travellerRotator), userInfo: nil, repeats: true)
        
        cleanupTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(GameScene.cleanUp), userInfo: nil, repeats: true)
        
        scoreTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(GameScene.updateScore), userInfo: nil, repeats: true)
        
        timers = [countDownTimer, obstacleTimer, travellerRotatorTimer, cleanupTimer, scoreTimer]
    }
    
    @objc func setUpCountdown () {
        if !isPaused {
            if countDownTime > 0 {
            
                countDownLabel = SKLabelNode()
                guard let countDownLabel = countDownLabel else { return }
                
                countDownLabel.fontSize = 144
                countDownLabel.fontName = "ArialMT"
                countDownLabel.fontColor = UIColor(red: 1, green: 0.35, blue: 0, alpha: 0.8)
                countDownLabel.zPosition = 50
                countDownLabel.text = String(countDownTime)
                
                addChild(countDownLabel)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    countDownLabel.removeFromParent()
                })
                
                countDownTime -= 1

            } else {
                travellerCreator?.unpauseTraveller()
                showGameplayNodes()
                countDownTimer?.invalidate()
                countDownTimer = nil
            }
        }
    }
    
    @objc func cleanUp() {
        for child in children {
            if child.position.x < -self.size.width - 30 {
                child.removeFromParent()
            }
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        if !isPaused {
            backgroundHandler?.moveBackground()

            enumerateChildNodes(withName: "obstacle", using: { (obstacle, stop) in
                let newItem = obstacle as! SKSpriteNode
                newItem.position.x -= 5 ///set the X speed
            })
        }
    }
    
    @objc func updateScore() {
        if !isPaused {
            scoreHandler?.updateScore()
        }
    }
    
    @objc func handleObstacleTimer(timer: Timer) {
        if !isPaused {
            obstacleCreator?.renderObstacles()
        }
    }
    
    @objc func travellerRotator() {
        travellerCreator?.rotate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
                
                let touchLocation = touch.location(in: self)
                
                switch atPoint(touchLocation).name {
                
                case "pauseLogo", "pauseLogoBackground":
                    isPaused.toggle()
                case "gameOverMenuLabel", "gameOverMenuBackground":
                    guard let menuScene = SKScene(fileNamed: "GameMenu") else { return }
                    menuScene.scaleMode = .aspectFill
                    view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.5))
                case "playAgainLabel", "playAgainBackground":
                    resetScene()
                default :
                    if !isPaused {
                        travellerCreator?.applyImpulse()
                    }
                }
            }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        isPaused = true
        hideGameplayNodes()
        travellerCreator?.updateTexture()
        scoreHandler?.checkHighScore()
        
        gameEndedView = GameEndedView(delegate: self, score: scoreHandler!.score, highScore: scoreHandler!.highScore)
        
        timers?.forEach{
            $0?.invalidate()
        }
    }
    
    func resetScene() {
        backgroundHandler = nil
        obstacleCreator = nil
        pauseButton = nil
        scoreHandler = nil
        travellerCreator = nil
        worldPhysics = nil
        gameEndedView = nil
        
        let gameScene = SKScene(fileNamed: "GameScene")!
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
