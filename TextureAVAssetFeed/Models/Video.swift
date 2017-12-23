import Foundation

struct Video {
    let url: URL
    let title: String
    let description: String
    
    init() {
        let list: [String] = [
            "http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8",
            "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
            "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8",
            "https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560.m3u8"
        ]
        
        let random = Int(arc4random_uniform(UInt32(list.count)))
        self.url = URL(string: list[random])!
        self.title = list[random].split(separator: "/").last?.decomposedStringWithCanonicalMapping ?? ""
        self.description = list[random]
    }
}
