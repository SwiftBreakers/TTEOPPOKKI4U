//
//  AppleTokenResponse.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/18/24.
//

import Foundation

struct AppleTokenResponse: Codable {
    let access_token: String?
    let expires_in: Int?
    let id_token: String?
    let refresh_token: String?
    let token_type: String?
}
