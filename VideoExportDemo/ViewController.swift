//  Copyright © 2019 Olli Brzoska. All rights reserved.

import UIKit
import AVKit

class ViewController: UIViewController {

    var videoPlayerVC: AVPlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videoURL : URL = Bundle.main.url(forResource: "AutomaticDataProcessingMachines", withExtension: "mp4") else { fatalError() }
        makeSureVideoIsNotCorruptByDisplayingIt(videoURL: videoURL)
        createAVideoAssetTrackAndTryToAccessItsAsset(url: videoURL)
        codeUsedInStackOverflowQuestion(videoInAppBundleURL: videoURL)
    }
    
    private func codeUsedInStackOverflowQuestion(videoInAppBundleURL: URL) {
        let asset = AVURLAsset(url: videoInAppBundleURL)
        let track = asset.tracks(withMediaType: .video).first!
        assert(track.asset != nil) // passes
        track.loadValuesAsynchronously(forKeys: [#keyPath(AVAssetTrack.asset)]) {
            assert(track.asset != nil) // passes
            DispatchQueue.main.async {
                assert(track.asset != nil) // FAILS
                // [...]
            }
        }
    }
    
    private func createAVideoAssetTrackAndTryToAccessItsAsset(url: URL) {
        // the problem persists also with other movies and file types (.mov, .mp4)
        createVideoAssetTrack(url: url) { (track) in
            print("track.asset: " + (track.asset == nil ? "NOT AVAILABLE" : "YEAH!"))
            track.loadValuesAsynchronously(forKeys: [#keyPath(AVAssetTrack.asset)]) {
                print("track.asset: " + (track.asset == nil ? "NOT AVAILABLE" : "YEAH!"))
                DispatchQueue.main.async {
                    print("track.asset: " + (track.asset == nil ? "NOT AVAILABLE" : "YEAH!"))
                }
            }
        }
    }
    
    private func createVideoAssetTrack(url: URL, completion: @escaping (AVAssetTrack) -> Void) {
        
        // it seems not to matter whether AVAsset or AVURLAsset is used here
        let asset = AVAsset(url: url)
        guard let track = asset.tracks(withMediaType: .video).first else { fatalError() }
        print("track.asset: " + (track.asset == nil ? "NOT AVAILABLE" : "YEAH!"))
        completion(track)
    }

    
    private func makeSureVideoIsNotCorruptByDisplayingIt(videoURL: URL) {
        videoPlayerVC.player = AVPlayer(url: videoURL)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        videoPlayerVC = (segue.destination as! AVPlayerViewController)
    }
}

