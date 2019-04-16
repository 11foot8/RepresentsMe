//
//  ProfilePictureSettingsViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/15/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

class ProfilePictureSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Properties
    let imagePicker = UIImagePickerController()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false

        imageView.image = AppState.profilePicture
        imageView.layer.cornerRadius = 100.0
        imageView.clipsToBounds = true
    }

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!

    // MARK: - Actions
    @IBAction func selectPictureTouchUp(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func saveTouchUp(_ sender: Any) {
        // Hide the keyboard
        self.view.endEditing(true)

        if let image = imageView.image {
            if image == DEFAULT_NOT_LOADED {
                // no new image
                self.alert(title: "No Image",
                           message: "No image was chosen.")
            } else {
                // Successfully built, save it
                self.save(image: image)
            }
        }
    }

    @IBAction func removeTouchUp(_ sender: Any) {
        self.remove()
    }

    /// Saves the image.
    ///
    /// - Parameter image:    the image to save
    private func save(image:UIImage) {
        // Start the loading animation
        self.navigationItem.hidesBackButton = true
        let hud = LoadingHUD(self.view)
        UsersDatabase.shared.changeUserProfilePicture(image: image, completion: { (error) in
            // Stop the loading animation
            hud.end()
            self.navigationItem.hidesBackButton = false
            if error != nil {
                // TODO: Handle error
                self.alert(title: "An Error Occured", message: error!.localizedDescription)
            } else {
                AppState.profilePicture = image
                self.alert(title: "Saved")
            }
        })
    }

    /// Removes the current user's profile picture
    private func remove() {
        // Start the loading animation
        self.navigationItem.hidesBackButton = true
        let hud = LoadingHUD(self.view)

        UsersDatabase.shared.removeUserProfilePicture { (error) in
            hud.end()
            self.navigationItem.hidesBackButton = false
            if let _ = error {
                self.alert(title: "An Error Occured", message: error!.localizedDescription)
            } else {
                self.imageView.image = DEFAULT_NOT_LOADED
                self.alert(title: "Saved")
            }
        }


    }
    
    // MARK: - ImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let newSize = CGSize(width: 1000, height: 1000)
            if let resizedImage = resizeImage(image: pickedImage, targetSize: newSize) {
                imageView.image = resizedImage
            } else {
                // TODO: Handle error
                print("Failed to resize image")
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
}
