//: Playground - noun: a place where people can play
import UIKit
import AsyncDisplayKit
import SnapKit

class VideoFeedViewController: UIViewController {
    
    struct Const {
        static let numberOfSection: Int = 1
        static let itemCount: Int = 100
    }
    
    let tableNode = ASTableNode(style: .plain)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tableNode.backgroundColor = .gray
        self.view.addSubnode(tableNode)
        tableNode.dataSource = self
        tableNode.onDidLoad({ _ in
            self.tableNode.view.separatorStyle = .none
            self.tableNode.view.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableNode.reloadData()
    }
}

extension VideoFeedViewController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return Const.numberOfSection
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return Const.itemCount
    }
    
    func tableNode(_ tableNodes: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = VideoCellNode()
        cell.configure(video: Video())
        return cell
    }
}
