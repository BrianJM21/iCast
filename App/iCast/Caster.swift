//
//  Caster.swift
//  iCast
//
//  Created by Brian Jiménez Moedano on 14/08/23.
//

import Foundation
import GoogleCast

final class Caster {
    
    static let shared = Caster()
    private let sessionManager: GCKSessionManager
    private var requesDelegate: GCKRequestDelegate?
    
    private init() {
        self.sessionManager = GCKCastContext.sharedInstance().sessionManager
    }
    
    func startCast(withURL url: URL, metaTitle: String = "", metaSubtitle: String = "", metaImage: MetaImageURLPath? = nil) {
        guard let requesDelegate else {
            print("Request Delegate for Caster class not assigned.")
            return
        }
        Task {
            let metadata = GCKMediaMetadata()
            metadata.setString(metaTitle, forKey: kGCKMetadataKeyTitle)
            metadata.setString(metaSubtitle, forKey: kGCKMetadataKeySubtitle)
            if let metaImage, let url = await MetaImageURLPath.getURL(for: metaImage) {
                metadata.addImage(GCKImage(url: url, width: 350, height: 350))
            }
            let mediaInfoBuilder = GCKMediaInformationBuilder.init(contentURL: url)
            mediaInfoBuilder.metadata = metadata
            let mediaInformation = mediaInfoBuilder.build()
            if let request =  self.sessionManager.currentSession?.remoteMediaClient?.loadMedia(mediaInformation) {
                request.delegate = requesDelegate
            }
        }
    }
    
    func startCastAsync(withURL url: URL) async {
        guard let requesDelegate else {
            print("Request Delegate for Caster class not assigned.")
            return
        }
        let mediaInfoBuilder = GCKMediaInformationBuilder.init(contentURL: url)
        mediaInfoBuilder.streamDuration = .infinity
        let mediaInformation = mediaInfoBuilder.build()
        if let request =  self.sessionManager.currentSession?.remoteMediaClient?.loadMedia(mediaInformation) {
            request.delegate = requesDelegate
        }
    }
    
    func assignRequestDelegate(_ delegate: GCKRequestDelegate) {
        requesDelegate = delegate
    }
    
    func assingListenerForReceivingNotifications(to vc: GCKSessionManagerListener) {
        sessionManager.add(vc)
    }
    
    func presentDefaultExpandedMediaControls() {
        GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
    }
    
    func createMiniMediaControlsViewController() -> GCKUIMiniMediaControlsViewController {
        return GCKCastContext.sharedInstance().createMiniMediaControlsViewController()
    }
}
