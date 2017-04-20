//
//  License
//  Copyright (c) 2017 chatappcodepath
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

class AppState: NSObject {

  static let sharedInstance = AppState()

  var signedIn = false
  var displayName: String?
  var photoURL: URL?
}
