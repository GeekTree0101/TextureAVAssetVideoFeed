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
    
    lazy var videoNode = { () -> GTVideoNode in
        let node = GTVideoNode(ratio: 0.5,
                               videoGravity: .resizeAspectFill,
                               playControlNode: self.playButton)
        node.backgroundColor = UIColor.black.withAlphaComponent(0.05)
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
    
    @objc func replay() {
        self.videoNode.replayVideo()
    }
}

extension VideoContentNode {
    func configure(video: Video) {
        self.titleNode.attributedText = TextStyle.title.attributedText(video.title)
        self.decriptionNode.attributedText = TextStyle.description.attributedText(video.description)
        self.videoNode.setVideoAsset(video.url, isCache: true)
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
