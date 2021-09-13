//
//  ParticleView.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 11/14/20.
//

import SpriteKit

class ParticleView: SKView {

    private(set) var particle: SKEmitterNode?

    var particleColor: UIColor = Theme.buttonActiveColor {
        didSet {
            particle?.particleColor = particleColor
        }
    }

    var particleImage: UIImage? {
        didSet {
            beginUpdate()
            
        }
    }

    var particleName: String = "" {
        didSet {
            particle?.removeFromParent()
            particle = nil
            commonInit()
        }
    }

    var isRandomColorEnabled: Bool = false {
        didSet {
            setupRandomColor()
            if !isRandomColorEnabled {
                particle?.particleColor = particleColor
            }
        }
    }

    init(frame: CGRect, fileNamed: String) {
        particleName = fileNamed
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    internal func commonInit() {
        backgroundColor = .clear
        if particleName.isEmpty == false,
           let emitter = SKEmitterNode(fileNamed: particleName) {
            emitter.position = CGPoint(x: frame.midX, y: frame.midY)
            let scene = SKScene(size: frame.size)
            scene.backgroundColor = .clear
            scene.addChild(emitter)
            presentScene(scene)
            particle = emitter

            endUpdate()
        }
    }

    private var randomColorTimer: Timer?
    private var randomColorIndex: Int = 0
    private let randomColors: [UIColor] = [.black, .white, .gray, .red, .green, .blue, .cyan, .yellow, .magenta, .orange, .purple, .brown]
    private func setupRandomColor() {

        if isRandomColorEnabled {
            randomColorTimer?.invalidate()
            randomColorTimer = nil
            randomColorTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [weak self] _ in
                guard let `self` = self else { return }
                if let color = self.randomColors[safe:self.randomColorIndex] {
                    self.particle?.particleColor = color
                }

                self.randomColorIndex += 1

                if self.randomColorIndex >= self.randomColors.count {
                    self.randomColorIndex = 0
                }
            })
        } else {
            randomColorTimer?.invalidate()
            randomColorTimer = nil
        }
    }

    deinit {
        randomColorTimer?.invalidate()
        randomColorTimer = nil
    }

    public func endUpdate() {
        particle?.isHidden = true
        particle?.isPaused = true
    }

    public func beginUpdate() {
        if let particleImage = particleImage {
            particle?.particleTexture = SKTexture(image: particleImage)
        }
        particle?.isHidden = false
        particle?.isPaused = false
        particle?.particlePositionRange = CGVector(dx: frame.width,
                                                   dy: frame.height)
        particle?.particleColor = particleColor
        particle?.particleColorBlendFactor = 1.0
        particle?.particleColorSequence = nil
    }

    public func update(average: Float,
                       yAcceleration: CGFloat = 0,
                       xAcceleration: CGFloat = 0) {
        particle?.particleScaleSpeed = CGFloat(abs(average))
        particle?.particleScaleRange = CGFloat(abs(average))
        particle?.particleScale = CGFloat(average)
        particle?.yAcceleration = yAcceleration
        particle?.xAcceleration = xAcceleration
    }
}
