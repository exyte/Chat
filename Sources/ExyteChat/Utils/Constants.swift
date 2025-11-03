//
//  File.swift
//  Chat
//
//  Created by ThanPD on 3/11/25.
//

import Foundation
import UIKit

let iPad = UIDevice.current.userInterfaceIdiom == .pad

struct Constants {
    static let marginSpacingInterface: CGFloat = iPad ? 32 : 16
}
