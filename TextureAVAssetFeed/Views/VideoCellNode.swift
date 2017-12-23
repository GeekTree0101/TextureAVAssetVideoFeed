import Foundation
import AsyncDisplayKit
import UIKit

class VideoCellNode: ASCellNode {
    lazy var videoNode = VideoContentNode()
    
    struct Const {
        static let insets: UIEdgeInsets = .init(top: 20.0,
                                                left: 15.0,
                                                bottom: 0.0,
                                                right: 15.0)
    }
    
    override init() {
        super.init()
        self.selectionStyle = .none
        self.automaticallyManagesSubnodes = true
    }
    
    func configure(video: Video) {
        videoNode.configure(video: video)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: Const.insets,
                                 child: videoNode)
    }
}

