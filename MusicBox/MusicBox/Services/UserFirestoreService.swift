//
//  FirebaseUserService.swift
//  MusicBox
//
//  Created by Mateus Martins Pires on 31/10/25.
//


import Foundation
import FirebaseFirestore

// Função de criar um usuário no banco de dados, e fazer um CRUD dele
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
}
