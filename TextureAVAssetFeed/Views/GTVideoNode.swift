import Foundation
import AsyncDisplayKit

class GTVideoNode: ASDisplayNode {
    fileprivate var state: VideoState? // video state
    private let ratio: CGFloat
    private let automaticallyPause: Bool // Recommend true
    private let videoGravity: AVLayerVideoGravity
    private var willCache: Bool = true
    private var playControlNode: ASDisplayNode?
    
    fileprivate lazy var videoNode = { () -> ASVideoNode in
        let node = ASVideoNode()
        node.shouldAutoplay = false
        node.shouldAutorepeat = false
        node.muted = true
        return node
    }()
    
    enum VideoState {
        case readyToPlay(URL)
        case play(URL)
        case pause(URL)
    }
    
    required init(ratio: CGFloat,
                  videoGravity: AVLayerVideoGravity,
                  automaticallyPause: Bool = true,
                  playControlNode: ASDisplayNode?) {
        self.ratio = ratio
        self.videoGravity = videoGravity
        self.automaticallyPause = automaticallyPause
        self.playControlNode = playControlNode
        super.init()
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASRatioLayoutSpec(ratio: self.ratio, child: self.videoNode)
    }
    
    func setPlayControlNode(_ node: ASDisplayNode) {
        self.playControlNode = node
    }
    
    func setVideoAsset(_ url: URL, isCache: Bool = true) {
        self.willCache = isCache
        self.state = .readyToPlay(url)
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"], completionHandler: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0, execute: {
                asset.cancelLoading()
                self.videoNode.asset = asset
            })
        })
    }
}

// MARK - Intelligent Preloading LifeCycle
extension GTVideoNode {
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        self.playVideo()
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        if automaticallyPause {
            self.pauseVideo()
        }
    }
}

// MARK - Video ControlEvent
extension GTVideoNode {
    func replayVideo() {
        guard let state = self.state, case .pause(let url) = state else { return }
        self.state = .readyToPlay(url)
        self.playVideo(forcePlay: true)
    }
    
    func playVideo(forcePlay: Bool = false) {
        guard let state = self.state, case .readyToPlay(let url) = state else { return }
        self.videoNode.play()
        self.videoNode.playerLayer?.videoGravity = self.videoGravity
        self.playControlNode?.isHidden = true
        self.state = .play(url)
    }
    
    func pauseVideo() {
        guard let state = self.state, case .play(let url) = state else { return }
        self.videoNode.pause()
        self.videoNode.asset?.cancelLoading()
        self.playControlNode?.isHidden = false
        if !self.willCache {
            self.videoNode.asset = nil
        }
        self.state = .pause(url)
    }
}
