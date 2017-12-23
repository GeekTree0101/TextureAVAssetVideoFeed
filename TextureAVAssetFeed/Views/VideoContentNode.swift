import Foundation
import AsyncDisplayKit

class VideoContentNode: ASDisplayNode {
    
    var state: VideoState? // video state
    
    struct Const {
        static let videoRatio: CGFloat = 0.5
        static let stackSpacing: CGFloat = 2.0
        static let insets: UIEdgeInsets = .init(top: 20.0,
                                                left: 15.0,
                                                bottom: 20.0,
                                                right: 15.0)
        static let playIconSize: CGSize = .init(width: 60.0, height: 60.0)
        
        static let forgroundColorKey = NSAttributedStringKey.foregroundColor
        static let fontKey = NSAttributedStringKey.font
    }
    
    enum VideoState {
        case readyToPlay(URL)
        case play(URL)
        case pause(URL)
    }
    
    lazy var playButton = { () -> ASButtonNode in
        let node = ASButtonNode()
        node.setImage(#imageLiteral(resourceName: "icPlay"), for: .normal)
        node.contentMode = .scaleAspectFill
        node.clipsToBounds = true
        node.style.preferredSize = Const.playIconSize
        node.addTarget(self, action: #selector(self.replay), forControlEvents: .touchUpInside)
        return node
    }()
    
    lazy var videoNode = { () -> ASVideoNode in
        let node = ASVideoNode()
        node.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        node.shouldAutoplay = false
        node.shouldAutorepeat = false
        node.muted = true
        return node
    }()
    
    lazy var titleNode = { () -> ASTextNode in
        let node = ASTextNode()
        node.backgroundColor = .white
        node.maximumNumberOfLines = 2
        return node
    }()
    
    lazy var decriptionNode = { () -> ASTextNode in
        let node = ASTextNode()
        node.backgroundColor = .white
        node.maximumNumberOfLines = 5
        return node
    }()
    
    enum TextStyle {
        case title
        case description
        
        var fontStyle: UIFont {
            switch self {
            case .title: return UIFont.systemFont(ofSize: 14.0,
                                                  weight: UIFont.Weight.bold)
            case .description: return UIFont.systemFont(ofSize: 10.0,
                                                    weight: UIFont.Weight.regular)
            }
        }
        
        var fontColor: UIColor {
            switch self {
            case .title: return UIColor.black
            case .description: return UIColor.gray
            }
        }
        
        func attributedText(_ text: String) -> NSAttributedString {
            let attr = [Const.forgroundColorKey: self.fontColor,
                        Const.fontKey: self.fontStyle]
            return NSAttributedString(string: text,
                                      attributes: attr)
        }
    }
    
    override init() {
        super.init()
        self.backgroundColor = .white
        self.automaticallyManagesSubnodes = true
    }
}

extension VideoContentNode {
    func configure(video: Video) {
        self.titleNode.attributedText = TextStyle.title.attributedText(video.title)
        self.decriptionNode.attributedText = TextStyle.description.attributedText(video.description)
        self.cachingAssetOnVideoNode(video.url)
    }
    
    func cachingAssetOnVideoNode(_ url: URL) {
        // update state
        self.state = .readyToPlay(url)
        
        // create asset
        let asset = AVAsset(url: url)
        
        // load asynchronusly
        asset.loadValuesAsynchronously(forKeys: ["playable"], completionHandler: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0, execute: {
                // don't auto loading
                asset.cancelLoading()
                
                // set assset on ASVideoNode
                self.videoNode.asset = asset
            })
        })
    }
}

// MARK - LayoutSpec
extension VideoContentNode {
    func videoRatioLayout() -> ASLayoutSpec {
        let videoRatioLayout = ASRatioLayoutSpec(ratio: Const.videoRatio,
                                                 child: self.videoNode)
        let playButtonCenterLayout = ASCenterLayoutSpec(centeringOptions: .XY,
                                                        sizingOptions: [],
                                                        child: playButton)
        return ASOverlayLayoutSpec(child: videoRatioLayout,
                                   overlay: playButtonCenterLayout)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackLayoutSpec = ASStackLayoutSpec(direction: .vertical,
                                                spacing: Const.stackSpacing,
                                                justifyContent: .start,
                                                alignItems: .stretch,
                                                children: [videoRatioLayout(),
                                                           titleNode,
                                                           decriptionNode])
        return ASInsetLayoutSpec(insets: Const.insets, child: stackLayoutSpec)
    }
}

// MARK - Intelligent Preloading LifeCycle
extension VideoContentNode {
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        self.play()
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        self.pause()
    }
}

// MARK - Video ControlEvent
extension VideoContentNode {
    @objc func replay() {
        guard let state = self.state, case .pause(let url) = state else { return }
        self.state = .readyToPlay(url)
        self.play(forcePlay: true)
    }
    
    func play(forcePlay: Bool = false) {
        guard let state = self.state, case .readyToPlay(let url) = state else { return }
        self.videoNode.play()
        self.playButton.isHidden = true
        self.videoNode.playerLayer?.videoGravity = .resizeAspectFill
        self.state = .play(url)
    }
    
    func pause() {
        guard let state = self.state, case .play(let url) = state else { return }
        self.videoNode.pause()
        self.playButton.isHidden = false
        self.videoNode.asset?.cancelLoading()
        self.state = .pause(url)
    }
}
