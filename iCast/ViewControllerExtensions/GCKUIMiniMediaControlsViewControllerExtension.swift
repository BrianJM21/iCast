//
//  GCKUIMiniMediaControlsViewControllerExtension.swift
//  iCast
//
//  Created by Brian Jiménez Moedano on 16/08/23.
//

import Foundation
import GoogleCast

extension ViewController: GCKUIMiniMediaControlsViewControllerDelegate {
    
    func miniMediaControlsViewController(_ miniMediaControlsViewController: GCKUIMiniMediaControlsViewController, shouldAppear: Bool) {
        updateControlBarsVisibility(shouldAppear: shouldAppear)
    }
    
    
}
