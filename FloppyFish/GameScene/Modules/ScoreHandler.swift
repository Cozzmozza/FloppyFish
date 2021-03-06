//
//  ScoreHandler.swift
//  FloppyFish
//
//  Created by Colin Morrison on 12/12/2021.
//

import SpriteKit

class ScoreHandler {
        
    private var delegate: SKScene
    
    private(set) var score = Int(-2)
    private(set) var highScore = UserDefaults.standard.integer(forKey: "highScore")

    private(set) var scoreLabel: SKLabelNode?
    private(set) var scoreBackground: SKShapeNode?
    
    init(delegate: SKScene) {
        self.delegate = delegate
        renderScoreBackground(parent: delegate)
    }
    
    func renderScoreBackground(parent: SKScene) {
        let scoreBackgroundSize = CGSize(width: 120, height: 70)
        scoreBackground = SKShapeNode(rectOf: scoreBackgroundSize, cornerRadius: 10)
        
        guard let scoreBackground = scoreBackground else { return }
        
        scoreBackground.name = "scoreBackground"
        
        scoreBackground.position = CGPoint(x: -parent.size.width * 0.3,
                                           y: parent.size.height * 0.4)
        scoreBackground.zPosition = 35
        scoreBackground.fillColor = .white
        scoreBackground.alpha = 0.6
        
        renderScoreLabel(parent: scoreBackground)
        parent.addChild(scoreBackground)
    }

    func renderScoreLabel(parent: SKShapeNode) {
        scoreLabel = SKLabelNode()
        
        guard let scoreLabel = scoreLabel else { return }
        
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 50
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        
        scoreLabel.fontName = "Arial-BoldMT"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = UIColor(r: 255, g: 80, b: 0)
        scoreLabel.text = String(0)
        
        parent.addChild(scoreLabel)
    }
    
    func updateScore() {
        score += 1
        scoreLabel?.text = String(score)
    }
    
    func checkHighScore() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "highScore")
        }
    }
    
    func hide() {
        delegate.childNode(withName: "scoreBackground")?.isHidden = true
    }
    
    func show() {
        delegate.childNode(withName: "scoreBackground")?.isHidden = false
    }
    
    private func attributedShadowedText(string: String, font: String, size: CGFloat, color: UIColor, shadowSize: CGFloat, shadowColor: UIColor) -> NSAttributedString {
        
        let shadow = NSShadow()
        shadow.shadowBlurRadius = shadowSize
        shadow.shadowOffset = CGSize(width: shadowSize, height: shadowSize)
        shadow.shadowColor = shadowColor
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: font, size: size) ?? UIFont.systemFont(ofSize: size),
            .foregroundColor: color,
            .shadow: shadow
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
}
