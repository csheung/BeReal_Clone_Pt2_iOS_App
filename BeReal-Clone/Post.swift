//
//  Post.swift
//  BeReal-Clone
//
//  Created by Derrick Ng on 3/22/23.
//

import Foundation
import ParseSwift
import CoreLocation


/// Pt 1 - Create Post Parse Object model
struct Post: ParseObject {
    // These are required by ParseObject
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Your own custom properties.
    var caption: String?
    var user: User?
    var imageFile: ParseFile?
    var location: String?
}


// Reference: https://github.com/parse-community/Parse-Swift/blob/3d4bb13acd7496a49b259e541928ad493219d363/ParseSwift.playground/Pages/1%20-%20Your%20first%20Object.xcplaygroundpage/Contents.swift#L33
