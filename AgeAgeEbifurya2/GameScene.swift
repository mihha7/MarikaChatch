//
//  GameScene.swift
//  AgeAgeEbifurya2
//
//  Created by 西村 美陽 on 2015/06/13.
//  Copyright (c) 2015年 Miharu Nishimura. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - 定数定義
    /// 定数
    struct Constants {
        /// Player画像
        static let PlayerImages = ["shrimp01", "shrimp02", "shrimp03", "shrimp04"]

    }
    
    /// 衝突の判定につかうBitMask
    struct ColliderType {
        /// プレイキャラに設定するカテゴリ
        static let Player: UInt32 = (1 << 0)
        /// 天井・地面に設定するカテゴリ
        static let World: UInt32  = (1 << 1)
        /// サンゴに設定するカテゴリ
        static let Coral: UInt32  = (1 << 2)
        /// スコア加算用SKNodeに設定するカテゴリ
        static let Score: UInt32  = (1 << 3)
        /// スコア加算用SKNodeに衝突した際に設定するカテゴリ
        static let None: UInt32   = (1 << 4)
        ///　爆弾
        static let Bakudan: UInt32 = (1 << 5)
        /// スイーツ（チョコドーナツ）
        static let Sweets: UInt32 = (1 << 6)
        /// スイーツ（プレーンドーナツ）
        static let Sweers2: UInt32 = (1 << 7)
    }
    
    // MARK: - 変数定義
    /// プレイキャラ以外の移動オブジェクトを追加する空ノード
    var baseNode: SKNode!
    /// サンゴ関連のオブジェクトを追加する空ノード(リスタート時に活用)
    var coralNode: SKNode!
    
    ///　爆弾のオブジェクトを追加する空ノード（bymihha）
    var bakudanNode: SKNode!
    
    /// プレイキャラ
    var player: SKSpriteNode!
    
    /// スイーツ（bymihha）
    var sweets: SKNode!
    
    var sweets2: SKNode!
    
    /// スコアを表示するラベル
    var scoreLabelNode: SKLabelNode!
    /// スコアの内部変数
    var score: UInt32!
    
    // MARK: - 関数定義
    
    override func didMoveToView(view: SKView) {
        // 変数の初期化
        score = 0
        
        // 物理シミュレーションを設定
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        self.physicsWorld.contactDelegate = self
        
        // 全ノードの親となるノードを生成
        baseNode = SKNode()
        baseNode.speed = 1.0
        self.addChild(baseNode)
        
        // 障害物（爆弾用）を追加するノードを生成
        bakudanNode = SKNode()
        baseNode.addChild(bakudanNode)
        
        //得点を追加するノードを生成？（bymihha）
        coralNode = SKNode()
        baseNode.addChild(coralNode)
        
        // 背景画像を構築
        self.setupBackgroundSea()
        // 背景の岩山画像を構築
        self.setupBackgroundRock()
        // 天井と地面を構築
        self.setupCeilingAndLand()
        // プレイキャラを構築
        self.setupPlayer()
        // 障害物のサンゴ（爆弾）を構築
        self.setupCoral()
        // 特典になるスイーツを構築（bymihha）
        self.setupSweets()
        self.setupSweets2()
        // スコアラベルの構築
        self.setupScoreLabel()
    
    }
    
    /// 背景画像を構築
    func setupBackgroundSea() {
        // 背景画像を読み込む
        let texture = SKTexture(imageNamed: "background")
        texture.filteringMode = .Nearest
        
        // 必要な画像枚数を算出
        let needNumber = 2.0 + (self.frame.size.width / texture.size().width)
        
        // 左に画像一枚分移動アニメーションを作成
        let moveAnim = SKAction.moveByX(-texture.size().width, y: 0.0, duration: NSTimeInterval(texture.size().width / 10.0))
        // 元の位置に戻すアニメーションを作成
        let resetAnim = SKAction.moveByX(texture.size().width, y: 0.0, duration: 0.0)
        // 移動して元に戻すアニメーションを繰り返すアニメーションを作成
        let repeatForeverAnim = SKAction.repeatActionForever(SKAction.sequence([moveAnim, resetAnim]))
        
        // 画像の配置とアニメーションを設定
        for var i:CGFloat = 0; i < needNumber; ++i {
            // SKTextureからSKSpriteNodeを作成
            let sprite = SKSpriteNode(texture: texture)
            // 一番奥に配置
            sprite.zPosition = -100.0
            // 画像の初期位置を設定
            sprite.position = CGPoint(x: i * sprite.size.width, y: self.frame.size.height / 2.0)
            // アニメーションを設定
            sprite.runAction(repeatForeverAnim)
            // 親ノードに追加
            baseNode.addChild(sprite)
        }
    }
    
    /// 背景の岩山画像を構築
    func setupBackgroundRock() {
        // 岩山(下)画像を読み込む
        let under = SKTexture(imageNamed: "rock_under")
        under.filteringMode = .Nearest
        
        // 必要な画像枚数を算出
        var needNumber = 2.0 + (self.frame.size.width / under.size().width)
        
        // 左に画像一枚分移動アニメーションを作成
        let moveUnderAnim = SKAction.moveByX(-under.size().width, y: 0.0, duration:NSTimeInterval(under.size().width / 20.0))
        // 元の位置に戻すアニメーションを作成
        let resetUnderAnim = SKAction.moveByX(under.size().width, y: 0.0, duration: 0.0)
        // 移動して元に戻すアニメーションを繰り返すアニメーションを作成
        let repeatForeverUnderAnim = SKAction.repeatActionForever(SKAction.sequence([moveUnderAnim, resetUnderAnim]))
        
        // 画像の配置とアニメーションを設定
        for var i:CGFloat = 0; i < needNumber; ++i {
            // SKTextureからSKSpriteNodeを作成
            let sprite = SKSpriteNode(texture: under)
            // 背景画像より手前に設定
            sprite.zPosition = -50.0
            // 画像の初期位置を設定
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0 )
            // アニメーションを設定
            sprite.runAction(repeatForeverUnderAnim)
            // 親ノードに追加
            baseNode.addChild(sprite)
        }
        
        // 岩山(上)画像を読み込む
        let above = SKTexture(imageNamed: "rock_above")
        above.filteringMode = .Nearest
        
        // 必要な画像枚数を算出
        needNumber = 2.0 + (self.frame.size.width / above.size().width)
        
        // 左に画像一枚分移動アニメーションを作成
        let moveAboveAnim = SKAction.moveByX(-above.size().width, y: 0.0, duration:NSTimeInterval(above.size().width / 20.0))
        // 元の位置に戻すアニメーションを作成
        let resetAboveAnim = SKAction.moveByX(above.size().width, y: 0.0, duration: 0.0)
        // 移動して元に戻すアニメーションを繰り返すアニメーションを作成
        let repeatForeverAboveAnim = SKAction.repeatActionForever(SKAction.sequence([moveAboveAnim, resetAboveAnim]))
        
        // 画像の配置とアニメーションを設定
        for var i:CGFloat = 0; i < needNumber; ++i {
            // SKTextureからSKSpriteNodeを作成
            let sprite = SKSpriteNode(texture: above)
            // 背景画像より手前に設定
            sprite.zPosition = -50.0
            // 画像の初期位置を設定
            sprite.position = CGPoint(x: i * sprite.size.width, y: self.frame.size.height - (sprite.size.height / 2.0))
            // アニメーションを設定
            sprite.runAction(repeatForeverAboveAnim)
            // 親ノードに追加
            baseNode.addChild(sprite)
        }
    }
    
    /// 天井と地面を構築
    func setupCeilingAndLand() {
        // 地面画像を読み込み
        let land = SKTexture(imageNamed: "land")
        land.filteringMode = .Nearest
        
        // 必要な画像枚数を算出
        let needNumber = 2.0 + (self.frame.size.width / land.size().width)
        
        // 左に画像一枚分移動アニメーションを作成
        let moveLandAnim = SKAction.moveByX(-land.size().width, y: 0.0, duration:NSTimeInterval(land.size().width / 100.0))
        // 元の位置に戻すアニメーションを作成
        let resetLandAnim = SKAction.moveByX(land.size().width, y: 0.0, duration: 0.0)
        // 移動して元に戻すアニメーションを繰り返すアニメーションを作成
        let repeatForeverLandAnim = SKAction.repeatActionForever(SKAction.sequence([moveLandAnim, resetLandAnim]))
        
        // 画像の配置とアニメーションを設定
        for var i:CGFloat = 0.0; i < needNumber; ++i {
            // SKTextureからSKSpriteNodeを作成
            let sprite = SKSpriteNode(texture: land)
            // 画像の初期位置を設定
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0)
            
            // 画像に物理シミュレーションを設定
            sprite.physicsBody = SKPhysicsBody(texture: land, size: land.size())
            sprite.physicsBody?.dynamic = false
            sprite.physicsBody?.categoryBitMask = ColliderType.World
            // アニメーションを設定
            sprite.runAction(repeatForeverLandAnim)
            // 親ノードに追加
            baseNode.addChild(sprite)
        }
        
        /*天井画像は使わないので消してみるbymihha
        // 天井画像を読み込み
        let ceiling = SKTexture(imageNamed: "ceiling")
        ceiling.filteringMode = .Nearest
        
        // 必要な画像枚数を算出
        needNumber = 2.0 + self.frame.size.width / ceiling.size().width
        
        // 画像の配置とアニメーションを設定
        for var i:CGFloat = 0.0; i < needNumber; i++ {
            // SKTextureからSKSpriteNodeを作成
            let sprite = SKSpriteNode(texture: ceiling)
            // 画像の初期位置を設定
            sprite.position = CGPoint(x: i * sprite.size.width, y: self.frame.size.height - sprite.size.height / 2.0)
            
            // 画像に物理シミュレーションを設定
            sprite.physicsBody = SKPhysicsBody(texture: ceiling, size: ceiling.size())
            sprite.physicsBody?.dynamic = false
            sprite.physicsBody?.categoryBitMask = ColliderType.World
            // アニメーションを設定
            sprite.runAction(repeatForeverLandAnim)
            // 親ノードに追加
            baseNode.addChild(sprite)
        }*/
    }
    
    /// プレイヤーを構築
    func setupPlayer() {
        // Playerのパラパラアニメーション作成に必要なSKTextureクラスの配列を定義
        var playerTexture = [SKTexture]()
        
        // パラパラアニメーションに必要な画像を読み込む
        for imageName in Constants.PlayerImages {
            let texture = SKTexture(imageNamed: imageName)
            texture.filteringMode = .Linear
            playerTexture.append(texture)
        }
        
        // キャラクターのアニメーションをパラパラ漫画のように切り替える
        let playerAnimation = SKAction.animateWithTextures(playerTexture, timePerFrame: 0.2)
        // パラパラアニメーションをループさせる
        let loopAnimation = SKAction.repeatActionForever(playerAnimation)
        
        // キャラクターを生成
        player = SKSpriteNode(texture: playerTexture[0])
        // 初期表示位置を設定
        player.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
        
        // アニメーションを設定
        player.runAction(loopAnimation)
        
        // 物理シミュレーションを設定
        player.physicsBody = SKPhysicsBody(texture: playerTexture[0], size: playerTexture[0].size())
        player.physicsBody?.dynamic = true
        player.physicsBody?.allowsRotation = false
        
        // 自分自身にPlayerカテゴリを設定
        player.physicsBody?.categoryBitMask = ColliderType.Player
        /*
        // 衝突判定相手にWorldとCoralを設定
        player.physicsBody?.collisionBitMask = ColliderType.World | ColliderType.Coral
        player.physicsBody?.contactTestBitMask = ColliderType.World | ColliderType.Coral
        */
        // 衝突判定相手を上下の地面だけにしてみる（さんごは当たってもOK？）by：mihha
        /*
        player.physicsBody?.collisionBitMask = ColliderType.World
        player.physicsBody?.contactTestBitMask = ColliderType.World*/
        //　衝突判定相手をUnderのさんごのみにしてみる。bymihha
        player.physicsBody?.collisionBitMask = ColliderType.Bakudan | ColliderType.World
        player.physicsBody?.contactTestBitMask = ColliderType.Bakudan
        
        
        self.addChild(player)
        print(player.position)
        
    }
    
    ///  障害物（爆弾！）を構築
    func setupCoral() {
        // 爆弾の画像を読み込み
        let coralUnder = SKTexture(imageNamed: "coral_under")
        coralUnder.filteringMode = .Linear
        
        // 移動する距離を算出
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * coralUnder.size().width)
        
        // 画面外まで移動するアニメーションを作成
        let moveAnim = SKAction.moveByX(-distanceToMove, y: 0.0, duration:NSTimeInterval(distanceToMove / 100.0))
        // 自身を取り除くアニメーションを作成
        let removeAnim = SKAction.removeFromParent()
        // 2つのアニメーションを順に実行するアニメーションを作成
        let coralAnim = SKAction.sequence([moveAnim, removeAnim])
        
        // 爆弾を生成するメソッドを呼び出すアニメーションを作成
        let newCoralAnim = SKAction.runBlock({
            // 爆弾に関するノードを乗せるノードを作成
            let coral = SKNode()
            coral.position = CGPoint(x: self.frame.size.width + coralUnder.size().width * 2, y: 0.0)
            coral.zPosition = -50.0
            
            // 地面から伸びるサンゴ（爆弾）のy座標を算出（地面からのサンゴを爆弾にしてみる）
            let height = UInt32(self.frame.size.height / 6)
            let y = CGFloat(arc4random_uniform(height * 4) + height)
            
            // 地面から伸びるサンゴ（爆弾）を作成（爆弾）
            let under = SKSpriteNode(texture: coralUnder)
            //x座標を100にして、ドーナツと位置をちょっとずらす。（ギモン：x座標もランダムにするには？）
            under.position = CGPoint(x: 100.0, y: y)
            
            // サンゴに物理シミュレーションを設定（爆弾）
            under.physicsBody = SKPhysicsBody(texture: coralUnder, size: under.size)
            under.physicsBody?.dynamic = false
            //下のサンゴだけ障害物にしてみる…↓bymihha
            under.physicsBody?.categoryBitMask = ColliderType.Bakudan
            under.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(under)
            
            
            /*
            // スコアをカウントアップするノードを作成
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: (above.size.width / 2.0) + 5.0, y: self.frame.height / 2.0)
            
            // スコアノードに物理シミュレーションを設定
            scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 10.0, height: self.frame.size.height))
            scoreNode.physicsBody?.dynamic = false
            scoreNode.physicsBody?.categoryBitMask = ColliderType.Score
            scoreNode.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(scoreNode)*/
            coral.runAction(coralAnim)

            self.bakudanNode.addChild(coral)
        })
        // 一定間隔待つアニメーションを作成
        let delayAnim = SKAction.waitForDuration(2.5)
        // 上記2つを永遠と繰り返すアニメーションを作成
        let repeatForeverAnim = SKAction.repeatActionForever(SKAction.sequence([newCoralAnim, delayAnim]))
        // この画面で実行
        self.runAction(repeatForeverAnim)
    }

    ///  特典になるスイーツを構築する（１つ目：チョコドーナツ）
    func setupSweets() {

//        // スイーツのランダム作成に必要なSKTextureクラスの配列を定義
//        var sweetsTexture = [SKTexture]()
//        
//        // スイーツを生成
//        sweets = SKSpriteNode(texture: sweetsTexture[0])
//        
//        // 物理シミュレーションを設定
//        sweets.physicsBody = SKPhysicsBody(texture: sweetsTexture[0], size: sweetsTexture[0].size())
//        sweets.physicsBody?.dynamic = true
//        sweets.physicsBody?.allowsRotation = false
//        
//        // 自分自身にSweetsカテゴリを設定
//        player.physicsBody?.categoryBitMask = ColliderType.Sweets
//
//        
//        
//        self.addChild(sweets)
        
        
        
        // スイーツ画像を読み込み
        let coralAbove = SKTexture(imageNamed: "coral_above")
        coralAbove.filteringMode = .Linear
        
        // 移動する距離を算出
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * coralAbove.size().width)
        
        // 画面外まで移動するアニメーションを作成
        let moveAnim = SKAction.moveByX(-distanceToMove, y: 0.0, duration:NSTimeInterval(distanceToMove / 100.0))
        // 自身を取り除くアニメーションを作成
        let removeAnim = SKAction.removeFromParent()
        // 2つのアニメーションを順に実行するアニメーションを作成
        let coralAnim = SKAction.sequence([moveAnim, removeAnim])
        
        // サンゴ（ドーナツ）を生成するメソッドを呼び出すアニメーションを作成
        let newCoralAnim = SKAction.runBlock({
            // サンゴ（ドーナツ）に関するノードを乗せるノードを作成
            let coral = SKNode()
            coral.position = CGPoint(x: self.frame.size.width + coralAbove.size().width * 2, y: 0.0)
            coral.zPosition = -50.0
            
            // 天井から伸びるサンゴ（ドーナツ）を作成
            let above = SKSpriteNode(texture: coralAbove)
            //let donuty = CGFloat(arc4random_uniform(height * 4) + height)
            // ギモン：ポジションをランダムに決めたい！どうすれば…？
            above.position = CGPoint(x: 0.0, y: 260.0 + (above.size.height / 2.0))
            
            
            // サンゴに物理シミュレーションを設定
            above.physicsBody = SKPhysicsBody(texture: coralAbove, size: above.size)
            above.physicsBody?.dynamic = false
            //サンゴを障害物にしないため消してみた↓bymihha
            //above.physicsBody?.categoryBitMask = ColliderType.Coral
            //above.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(above)
            
            /*
            // スコアをカウントアップするノードを作成
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: (above.size.width / 2.0) + 5.0, y: self.frame.height / 2.0)
            
            // スコアノードに物理シミュレーションを設定
            scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 10.0, height: self.frame.size.height))
            scoreNode.physicsBody?.dynamic = false
            scoreNode.physicsBody?.categoryBitMask = ColliderType.Score
            scoreNode.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(scoreNode)*/
            coral.runAction(coralAnim)
            
            self.coralNode.addChild(coral)
        })
        // 一定間隔待つアニメーションを作成
        let delayAnim = SKAction.waitForDuration(2.5)
        // 上記2つを永遠と繰り返すアニメーションを作成
        let repeatForeverAnim = SKAction.repeatActionForever(SKAction.sequence([newCoralAnim, delayAnim]))
        // この画面で実行
        self.runAction(repeatForeverAnim)
    }
    
    /// 2つ目の特典になるスイーツ（プレーンドーナツ）
    func setupSweets2() {
        // スイーツ画像を読み込み
        let donut2 = SKTexture(imageNamed: "D02")
        donut2.filteringMode = .Linear
        
        // 移動する距離を算出
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * donut2.size().width)
        
        // 画面外まで移動するアニメーションを作成
        let moveAnim = SKAction.moveByX(-distanceToMove, y: 0.0, duration:NSTimeInterval(distanceToMove / 100.0))
        // 自身を取り除くアニメーションを作成
        let removeAnim = SKAction.removeFromParent()
        // 2つのアニメーションを順に実行するアニメーションを作成
        let coralAnim = SKAction.sequence([moveAnim, removeAnim])
        
        // サンゴを生成するメソッドを呼び出すアニメーションを作成
        let newCoralAnim = SKAction.runBlock({
            // サンゴに関するノードを乗せるノードを作成
            let coral = SKNode()
            coral.position = CGPoint(x: self.frame.size.width + donut2.size().width * 2, y: 0.0)
            coral.zPosition = -50.0
            
            // 天井から伸びるサンゴを作成
            let above = SKSpriteNode(texture: donut2)
            above.position = CGPoint(x: 1.0, y: 60.0 + (above.size.height / 2.0))
            
            // サンゴに物理シミュレーションを設定
            above.physicsBody = SKPhysicsBody(texture: donut2, size: above.size)
            above.physicsBody?.dynamic = false
            coral.addChild(above)
            
            coral.runAction(coralAnim)
            
            self.coralNode.addChild(coral)
        })
        // 一定間隔待つアニメーションを作成
        let delayAnim = SKAction.waitForDuration(2.5)
        // 上記2つを永遠と繰り返すアニメーションを作成
        let repeatForeverAnim = SKAction.repeatActionForever(SKAction.sequence([newCoralAnim, delayAnim]))
        // この画面で実行
        self.runAction(repeatForeverAnim)

        
    }
    
    /// スコアラベルを構築
    func setupScoreLabel() {
        // フォント名"Arial Bold"でラベルを作成
        scoreLabelNode = SKLabelNode(fontNamed: "Arial Bold")
        // フォント色を黄色に設定
        scoreLabelNode.fontColor = UIColor.blackColor()
        // 表示位置を設定
        scoreLabelNode.position = CGPoint(x: self.frame.width / 2.0, y: self.frame.size.height * 0.9)
        // 最前面に表示
        scoreLabelNode.zPosition = 100.0
        // スコアを表示
        scoreLabelNode.text = String(score)
        
        self.addChild(scoreLabelNode)
    }
    
    /// プレイヤーのx軸を元に戻すためのメソッド
    func setUpPlayerX() {
                        // プレイヤーのx座標が0より小さくなって画面からはみ出ないようにしたい(bymihha)
                        if player.position.x < 0 {
                            //player.position = CGPoint(x: 112, y: player.position.y)
                            print("はみでたから戻す！ \(player.position)")
                            player.runAction(SKAction.moveToX(50, duration: 0.2))
                            player.runAction(SKAction.moveToY(100, duration: 0))
                        }
    }
    /// タッチ開始時
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // ゲーム進行中のとき
        
        if 0.0 < baseNode.speed {
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
                // プレイヤーに加えられている力をゼロにする
                player.physicsBody?.velocity = CGVector.zero
                // プレイヤーにy軸方向へ力を加える（x軸方向も加えてみるbymihha）
                player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 23.0))
            }
        } else if baseNode.speed == 0.0 && player.speed == 0.0 {
            // ゲームオーバー時はリスタート
            // 障害物を全て取り除く
            coralNode.removeAllChildren()
            
            // スコアをリセット
            score = 0
            scoreLabelNode.text = String(score)
            
            // プレイキャラを再配置
            player.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
            player.physicsBody?.velocity = CGVector.zero
            player.physicsBody?.collisionBitMask = ColliderType.World | ColliderType.Coral | ColliderType.Bakudan
            player.zRotation = 0.0
            
            // アニメーションを開始
            player.speed = 1.0
            baseNode.speed = 1.0
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        setUpPlayerX()
    }
    
    // MARK: - SKPhysicsContactDelegateプロトコルの実装
    /// 衝突開始時のイベントハンドラ
    func didBeginContact(contact: SKPhysicsContact) {

        // 既にゲームオーバー状態の場合
        if baseNode.speed <= 0.0 {
            return
        }
        
        let rawScoreType = ColliderType.Score
        let rawNoneType = ColliderType.None
        
        if (contact.bodyA.categoryBitMask & rawScoreType) == rawScoreType ||
            (contact.bodyB.categoryBitMask & rawScoreType) == rawScoreType {
                
                // スコアを加算しラベルに反映
                score = score + 1
                scoreLabelNode.text = String(score)

                //触れたドーナツだけを消したい（bymihha）
                //coralNode.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                print("あたった")
                print(player.position)
                //当たった瞬間にプレイヤーのx座標を元に戻したい…（bymihha）
                
                // スコアラベルをアニメーション
                let scaleUpAnim = SKAction.scaleTo(1.5, duration: 0.1)
                let scaleDownAnim = SKAction.scaleTo(1.0, duration: 0.1)
                scoreLabelNode.runAction(SKAction.sequence([scaleUpAnim, scaleDownAnim]))
                
                // スコアカウントアップに設定されているcontactTestBitMaskを変更
                if (contact.bodyA.categoryBitMask & rawScoreType) == rawScoreType {
                    contact.bodyA.categoryBitMask = ColliderType.None
                    contact.bodyA.contactTestBitMask = ColliderType.None
                } else {
                    contact.bodyB.categoryBitMask = ColliderType.None
                    contact.bodyB.contactTestBitMask = ColliderType.None
                }
        } else if (contact.bodyA.categoryBitMask & rawNoneType) == rawNoneType ||
            (contact.bodyB.categoryBitMask & rawNoneType) == rawNoneType {
                // なにもしない
        } else {
            // baseNodeに追加されたものすべてのアニメーションを停止
            baseNode.speed = 0.0
            
            // プレイキャラのBitMaskを変更
            player.physicsBody?.collisionBitMask = ColliderType.World
            // プレイキャラに回転アニメーションを実行
            let rolling = SKAction.rotateByAngle(CGFloat(M_PI) * player.position.y * 0.01, duration: 1.0)
            player.runAction(rolling, completion:{
                // アニメーション終了時にプレイキャラのアニメーションを停止
                self.player.speed = 0.0
            })
        }
    }
    
}