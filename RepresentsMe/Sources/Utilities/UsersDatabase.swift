//
//  UsersDatabase.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/4/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import Firebase

let MAX_PROF_PIC_SIZE: Int64 = 10 * 1024 * 1024 // MAX profile pic size is 10 MB

class UsersDatabase {
    static let collection = "users" // Database collection

    static let db = Firestore.firestore().collection(UsersDatabase.collection)

    static let imagesRef = Storage.storage().reference().child("images") // Profile Pictures database

    static let shared = UsersDatabase()
    private init() { }

    // MARK: - Current User Info
    static var currentUser: User? {
        return Auth.auth().currentUser
    }

    static var currentUserDisplayName: String? {
        return currentUser?.displayName
    }

    static var currentUserUID: String? {
        return currentUser?.uid
    }

    static var currentUserEmail: String? {
        return currentUser?.email
    }


    // MARK: - General User Info
    static func getCurrentUserAddress(completion:@escaping (Address?, Error?)->Void) {
        if let uid = currentUserUID {
            getUserAddress(uid: uid, completion: completion)
        } else {
            // TODO: Handle no current user error
        }
    }

    static func getUserAddress(uid:String,completion:@escaping (Address?, Error?)->Void) {
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

    /// Retrieves the current user's profile picture, and passes it to the closure
    ///
    /// - Parameter completion: the completion handler to run after
    ///                         received server response
    static func getCurrentUserProfilePicture(completion:@escaping (UIImage?, Error?) -> Void) {
        if let uid = currentUserUID {
            getUserProfilePicture(uid: uid, completion: completion)
        } else {
            // TODO: Handle no current user error
            completion(nil, NilValueError.runtimeError("Nil User ID"))
        }
    }

    /// Retrieves the given user's profile picture, and passes it to the closure
    ///
    /// - Parameter completion: the completion handler to run after
    ///                         received server response
    static func getUserProfilePicture(uid: String, completion: @escaping (UIImage?, Error?) -> Void) {
        if let image = AppState.imageCache.object(forKey: NSString(string: uid)) {
            return completion(image, nil)
        }

        let imageRef = imagesRef.child(uid)
        imageRef.getData(maxSize: MAX_PROF_PIC_SIZE) { (data, error) in
            if let _ = error {
                completion(nil, error)
            } else {
                let image = UIImage(data: data!)

                if let image = image {
                    AppState.imageCache.setObject(image, forKey: NSString(string: uid))
                }

                completion(image,nil)
            }
        }
    }

    // MARK: Create User

    /// Builds a User
    ///
    /// - Parameter email:          the user's email address
    /// - Parameter password:       the user's password
    /// - Parameter displayName:    the user's chosen display name
    /// - Parameter address:        the user's home address
    /// - Parameter completion:     the completion handler to run after
    ///                             receive server response
    func createUser(email:String, password:String, displayName:String, address:Address, completion:@escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let _ = error {
                // TODO: Handle error
                completion(error)
            } else {
                self.changeUserDisplayName(newDisplayName: displayName, completion: { (error) in
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

    /// Changes the current user's profile picture to the provided UIImage
    ///
    /// - Parameter image:          Image to use as the user's profile picture
    /// - Parameter completion:     the completion handler to run after
    ///                             receive server response
    func changeUserProfilePicture(image:UIImage, completion: @escaping (Error?) -> Void) {
        if let uid = UsersDatabase.currentUserUID {
            let imageRef = UsersDatabase.imagesRef.child(uid)
            if let data = image.pngData() {
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let _ = imageRef.putData(data, metadata: metadata) { (metadata, error) in
                    if let _ = error {
                        completion(error)
                    } else {
                        AppState.profilePicture = image
                        AppState.imageCache.setObject(image, forKey: NSString(string: uid))
                        imageRef.downloadURL(completion: { (url, error) in
                            if let _ = error {
                                completion(error)
                            } else {
                                // TODO: Execute completion handler
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.photoURL = url
                                changeRequest?.commitChanges(completion: { (error) in
                                    if let _ = error {
                                        completion(error)
                                        return
                                    } else {
                                        completion(nil)
                                    }
                                })
                            }
                        })
                    }
                }
            }
        }
    }
    /// Removes the current user's profile picture, and deletes the image
    ///     from the database
    ///
    /// - Parameter completion:     the completion handler to run after
    ///                             receive server response
    func removeUserProfilePicture(completion: @escaping (Error?) -> Void) {
        if let uid = UsersDatabase.currentUserUID {
            UsersDatabase.imagesRef.child(uid).delete { (error) in
                if let _ = error {
                    // TODO: Handle Error
                    completion(error)
                } else {
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.photoURL = nil
                    changeRequest?.commitChanges(completion: { (error) in
                        if let _ = error {
                            completion(error)
                            return
                        } else {
                            AppState.profilePicture = DEFAULT_NOT_LOADED
                            completion(nil)
                        }
                    })
                }
            }
        }
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
            Util.rememberMeEnabled = false
            Util.biometricEnabled = false
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
