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
    static let collection = "users"
    static let db = Firestore.firestore().collection(UsersDatabase.collection)

    static let shared = UsersDatabase()

    static func getInstance() -> UsersDatabase {
        return UsersDatabase.shared
    }

    private init() {

    }

    func createUser(email:String, password:String, displayName:String, streetAddress:String, city:String, state:String, zipcode:String, completion:@escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let _ = error {
                // TODO: Handle error
                print(error.debugDescription)
            } else {
                self.loginUser(withEmail: email, password: password, completion: { (uid, error) in
                    if let _ = error {
                        // TODO: Handle error
                        print(error.debugDescription)
                    } else {
                        if let user = Auth.auth().currentUser {
                            let uid = user.uid
                            let userData = ["displayName":displayName]
                            UsersDatabase.db.document(uid).setData(userData, completion: { (error) in
                                if let _ = error {
                                    // TODO: Handle error
                                    print(error.debugDescription)
                                }
                            })
                            self.setUserAddress(uid: uid, streetAddress: streetAddress, city: city, state: state, zipcode: zipcode)
                            completion(error)
                        } else {
                            // TODO: Handle no current user error
                        }
                    }
                })

            }
        }
    }

    func setUserAddress(uid:String, streetAddress:String, city:String, state:String, zipcode:String) {
        let userData = ["uid":uid,
                       "streetAddress":streetAddress,
                       "city":city,
                       "state":state,
                       "zipcode":zipcode]
        UsersDatabase.db.document(uid).updateData(userData, completion: { (error) in
            if let _ = error {
                // TODO: Handle error
                print(error.debugDescription)
            }
        })

    }

    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }

    func getUserAddress(uid:String,completion:@escaping (Address)->Void) {
        UsersDatabase.db.document(uid).getDocument { (document, error) in
            if let _ = error {
                // TODO: Handle error
                print(error.debugDescription)
            } else {
                if let data = document?.data() {
                    let address = Address(streetAddress: data["streetAddress"]  as! String,
                                          city: data["city"]                    as! String,
                                          state: data["state"]                  as! String,
                                          zipcode: data["zipcode"]              as! String)
                    completion(address)
                } else {
                    // TODO: Handle nil data
                }

            }
        }
    }

    func getCurrentUserAddress(completion:@escaping (Address)->Void) {
        getUserAddress(uid: getCurrentUser()!.uid, completion: completion)
    }

    func loginUser(withEmail email:String, password:String, completion:@escaping (String?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let _ = error {
                // TODO: Handle error
                print(error.debugDescription)
            } else {
                // TODO: Handle successful login
                completion(user?.user.uid,error)
            }
        }
    }
}
