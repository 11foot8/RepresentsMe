//
//  UsersDatabase.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/4/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import Firebase

class UsersDatabase {
    static let collection = "users" // Database collection

    static let db = Firestore.firestore().collection(UsersDatabase.collection)

    static let shared = UsersDatabase()

    private init() {

    }

    // MARK: - Create User
    /// Create a new user with the given email, password, display name, and address
    /// 
    func createUser(email:String, password:String, displayName:String, address:Address, completion:@escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let _ = error {
                // TODO: Handle error
                completion(error)
            } else {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = displayName
                changeRequest?.commitChanges(completion: { (error) in
                    if let _ = error {
                        // TODO: Handle error
                        completion(error)
                        return
                    } else {
                        self.loginUser(withEmail: email, password: password, completion: { (uid, error) in
                            if let _ = error {
                                // TODO: Handle error
                                completion(error)
                                return
                            } else {
                                // User successfully logged in
                                if let user = Auth.auth().currentUser {
                                    let uid = user.uid
                                    UsersDatabase.db.document(uid).setData(["uid":uid], completion: { (error) in
                                        if let _ = error {
                                            // TODO: Handle error
                                            completion(error)
                                        } else {
                                            self.setUserAddress(uid: uid, address: address, completion: completion)
                                        }
                                    })
                                } else {
                                    // TODO: Handle no current user error
                                    let error:Error = NoCurrentUserError.noCurrentUser
                                    completion(error)
                                    return
                                }
                            }
                        })
                    }
                })
            }
        }
    }

    func createDocumentForUser(uid:String) {

    }

    // MARK: - Current User Info
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }

    func getCurrentUserDisplayName() -> String? {
        return getCurrentUser()?.displayName
    }

    func getCurrentUserUID() -> String? {
        return getCurrentUser()?.uid
    }
    func getCurrentUserAddress(completion:@escaping (Address?, Error?)->Void) {
        if let uid = getCurrentUserUID() {
            getUserAddress(uid: uid, completion: completion)
        } else {
            // TODO: Handle no current user error
        }
    }

    func getCurrentUserEmail() -> String? {
        return getCurrentUser()?.email
    }

    // MARK: - General User Info
    func getUserAddress(uid:String,completion:@escaping (Address?, Error?)->Void) {
        UsersDatabase.db.document(uid).getDocument { (document, error) in
            if let _ = error {
                // TODO: Handle error
                print(error.debugDescription)
                completion(nil, error)
            } else {
                if let data = document?.data() {
                    let address = Address(streetAddress: data["streetAddress"]  as! String,
                                          city: data["city"]                    as! String,
                                          state: data["state"]                  as! String,
                                          zipcode: data["zipcode"]              as! String)
                    completion(address, nil)
                } else {
                    // TODO: Handle nil data
                }
            }
        }
    }

    // MARK: - Set user info
    func setUserAddress(uid:String, address:Address, completion:@escaping (Error?) -> Void) {
        let userData = ["uid":uid,
                        "streetAddress":address.streetAddress,
                        "city":address.city,
                        "state":address.state,
                        "zipcode":address.zipcode]
        UsersDatabase.db.document(uid).updateData(userData, completion: completion)
    }

    func changeUserEmail(currentEmail:String, password:String, newEmail:String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: currentEmail, password: password) { (user, error) in
            if let _ = error {
                // TODO: Handle error
                completion(error)
            } else {
                if let user = user {
                    user.user.updateEmail(to: newEmail, completion: { (error) in
                        if let _ = error {
                            // TODO: Handle error
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    })
                } else {
                    // TODO: Handle nil user
                    completion(NilValueError.runtimeError("Nil user"))
                }
            }
        }
    }

    func changeUserPassword(email:String, currentPassword:String, newPassword:String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: currentPassword) { (user, error) in
            if let _ = error {
                // TODO: Handle error
                completion(error)
            } else {
                if let user = user {
                    user.user.updatePassword(to: newPassword, completion: { (error) in
                        if let _ = error {
                            // TODO: Handle error
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    })
                } else {
                    // TODO: Handle nil user
                    completion(NilValueError.runtimeError("Nil user"))
                }
            }
        }
    }

    func changeUserDisplayName(newDisplayName:String, completion: @escaping (Error?) -> Void) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = newDisplayName
        changeRequest?.commitChanges(completion: { (error) in
            if let _ = error {
                // TODO: Handle error
                completion(error)
                return
            } else {
                completion(nil)
            }
        })
    }

    // MARK: - Login/Logout
    func loginUser(withEmail email:String, password:String, completion:@escaping (String?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let _ = error {
                // TODO: Handle error
                print(error.debugDescription)
                completion(nil,error)
            } else {
                // TODO: Handle successful login
                completion(user?.user.uid,nil)
            }
        }
    }

    func logoutUser(completion: @escaping (Error?) -> Void) {
        // TODO: Log user out
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let signOutError as NSError {
            // TODO: Handle sign out error
            completion(signOutError)
        }
    }
}

enum NoCurrentUserError:Error,LocalizedError {
    case noCurrentUser

    public var errorDescription: String? {
        switch self {
        case .noCurrentUser:
            return NSLocalizedString("No Current User", comment: "No Current User")
        }
    }
}

enum NilValueError: Error {
    case runtimeError(String)
}
