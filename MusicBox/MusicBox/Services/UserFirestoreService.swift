//
//  FirebaseUserService.swift
//  MusicBox
//
//  Created by Mateus Martins Pires on 31/10/25.
//


import Foundation
import FirebaseFirestore

class UserFirestoreService {
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userID: String) -> DocumentReference {
        userCollection.document(userID)
    }
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userID: user.userId).setData(from: user, merge: false)
    }
    
    func getUser(userID: String) async throws -> DBUser {
        try await userDocument(userID: userID).getDocument(as: DBUser.self)
    }
    
    func updateUserPremiumStatus(userID: String, isPremium: Bool) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.isPremium.rawValue : isPremium
        ]
        try await userDocument(userID: userID).updateData(data)
    }
    
    // ADD THIS METHOD if it doesn't exist:
    func fetchUsername(for userId: String) async throws -> String? {
        let user = try await getUser(userID: userId)
        return user.username // Make sure DBUser has a `username` property
    }
}
