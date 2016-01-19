//
//  SettingsTableViewController.swift
//  PubFeed
//
//  Created by Mike Gilroy on 06/01/2016.
//  Copyright © 2016 Mike Gilroy. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    
    private let kPhoto = "photo"
    var profilePhoto: UIImage?
    var user: User?
    var profilePhotoIdentifier: String?
    var mode: ViewMode = .defaultView
    var fieldsAreValid: Bool {
        switch mode {
            
        case .editView:
            return !(usernameTextField.text!.isEmpty) || (emailTextField.text!.isEmpty)
            
        case.defaultView:
            return (usernameTextField.text!.isEmpty) || (emailTextField.text!.isEmpty)
        }
    }
    
    
    enum ViewMode {
        case defaultView
        case editView
    }
    
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var updateProfilePhotoButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet var tableViewMain: UITableView!
    @IBOutlet weak var usernameLine: UIView!
    @IBOutlet weak var emailLine: UIView!
    @IBOutlet weak var editUpdateProfilePhotoButton: UIButton!
    
    // MARK: Actions
    
    func presentValidationAlertWithTitle(title: String, text: String) {
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.textColor = UIColor.darkGrayColor()
    }
    
    
    func updateViewForMode(mode: ViewMode) {
        switch mode {
            
        case .defaultView:
            
            //colors
            let defaultTextGrey = colorWithHexString("3c3c3c")
            
            //loads local profile image data from NSUserDefaults
            if let imageData = NSUserDefaults.standardUserDefaults().objectForKey(self.kPhoto) as? NSData {
                let image = UIImage(data: imageData)
                self.updateProfilePhotoButton.setBackgroundImage(image, forState: .Normal)
                self.updateProfilePhotoButton.titleLabel?.text = ""
                self.updateProfilePhotoButton.imageView?.contentMode = .ScaleToFill
            }
            
            if let user = UserController.sharedController.currentUser {
                usernameTextField.text = user.username
                emailTextField.text = user.email
                usernameTextField.userInteractionEnabled = false
                emailTextField.userInteractionEnabled = false
                usernameTextField.textColor = defaultTextGrey
                emailTextField.textColor = defaultTextGrey
            }
            
            saveButton.enabled = false
            
            editUpdateProfilePhotoButton.hidden = true
            
            updateProfilePhotoButton.userInteractionEnabled = false
            updateProfilePhotoButton.setTitle("", forState: .Normal)
            updateProfilePhotoButton.alpha = 1
            
            let editButton = UIBarButtonItem(image: UIImage(named: "editButton"), style: .Plain, target: self, action: "editButtonTapped:")
            self.navigationController?.navigationItem.leftBarButtonItem = editButton
            self.navigationItem.setLeftBarButtonItem(editButton, animated: true)
            
            ImageController.profilePhotoForIdentifier((UserController.sharedController.currentUser?.identifier)!) { (photoUrl) -> Void in
                
                if let photoUrl = photoUrl {
                    ImageController.fetchImageAtUrl(photoUrl, completion: { (image) -> () in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.updateProfilePhotoButton.setBackgroundImage(image, forState: .Normal)
                            self.updateProfilePhotoButton.titleLabel?.text = ""
                            self.updateProfilePhotoButton.imageView?.contentMode = .ScaleToFill
                        })
                    })
                } else {
                    
                    if let imageData = NSUserDefaults.standardUserDefaults().objectForKey(self.kPhoto) as? NSData {
                        let image = UIImage(data: imageData)
                        self.updateProfilePhotoButton.setBackgroundImage(image, forState: .Normal)
                        self.updateProfilePhotoButton.titleLabel?.text = ""
                        self.updateProfilePhotoButton.imageView?.contentMode = .ScaleToFill
                    }
                }
            }
            
            
        case .editView:
            
            editUpdateProfilePhotoButton.hidden = false
            editUpdateProfilePhotoButton.alpha = 1.0
            
            usernameTextField.text = UserController.sharedController.currentUser?.username
            emailTextField.text = UserController.sharedController.currentUser?.email
            usernameTextField.userInteractionEnabled = true
            emailTextField.userInteractionEnabled = true
            usernameTextField.enabled = true
            emailTextField.enabled = true
            usernameTextField.textColor = UIColor.lightGrayColor()
            emailTextField.textColor = UIColor.lightGrayColor()
            
            let pubGreen = colorWithHexString("6AFF63")
            
            saveButton.enabled = true
            updateProfilePhotoButton.enabled = true
            updateProfilePhotoButton.alpha = 0.30
            updateProfilePhotoButton.userInteractionEnabled = true
            updateProfilePhotoButton.setTitleColor(pubGreen, forState: .Normal)
            
            let cancelButton = UIBarButtonItem(title: "X", style: .Plain, target: self, action: "editButtonTapped:")
            self.navigationController?.navigationItem.leftBarButtonItem = cancelButton
            self.navigationItem.setLeftBarButtonItem(cancelButton, animated: true)
        }
    }
    
    
    
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        
        if let buttonAppearance = sender.image {
            switch buttonAppearance {
            case UIImage(named: "editButton")!:
                self.mode = .editView
                updateViewForMode(mode)
            case "X":
                self.mode = .defaultView
                updateViewForMode(mode)
            default:
                updateViewForMode(mode)
            }
        }
        if let buttonTitle = sender.title {
            switch buttonTitle {
            case "X":
                self.mode = .defaultView
                updateViewForMode(mode)
            default:
                updateViewForMode(mode)
            }
        }
    }
    
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        
        if (usernameTextField.text == "") || (emailTextField.text == "") {
            ErrorHandling.defaultErrorHandler(nil, title: "Missing Information in both fields.  Please supply missing field.")
            
            if usernameTextField.text == "" {
                usernameTextField.text = UserController.sharedController.currentUser?.username
            }
            //if text fields aren't changed, save photo
            if (usernameTextField.text == UserController.sharedController.currentUser?.username) || (emailTextField.text == UserController.sharedController.currentUser?.email) {
            }
            
        } else {
            
            UserController.updateUser(UserController.sharedController.currentUser!, username: usernameTextField.text!, email: emailTextField.text!, completion: { (user, error) -> Void in
                
                if let user = UserController.sharedController.currentUser {
                    
                    self.presentValidationAlertWithTitle("Success!", text: "Thank you, \(user.username), your account at \(user.email) has been updated.")
                    
                    if error == nil {
                        self.updateViewForMode(ViewMode.defaultView)
                    }
                    
                } else {
                    ErrorHandling.defaultErrorHandler(error, title: "\(error?.localizedDescription)")
                }
            })
        }
        self.updateViewForMode(ViewMode.defaultView)
    }
    
    
    @IBAction func deleteAccountTapped(sender: AnyObject) {
        var inputTextField: UITextField?
        let alertController = UIAlertController(title: "Are you sure you want to delete your account?", message: "Please enter password.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action) -> Void in }))
        
        alertController.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            if let userPasswordInput = inputTextField?.text {
                
                UserController.deleteUser(UserController.sharedController.currentUser!, password: userPasswordInput) { (errors) -> Void in
                    if let error = errors?.last {
                        ErrorHandling.defaultErrorHandler(error, title: "\(error.localizedDescription)")
                    } else {
                        let successAlertController = UIAlertController(title: "Success!", message: "Your account has been deleted.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        successAlertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            UserController.sharedController.currentUser = nil
                            self.performSegueWithIdentifier("fromSettings", sender: nil)
                        }))
                        
                        self.presentViewController(successAlertController, animated: true, completion: nil)
                    }
                }
            }
        }))
        alertController.addTextFieldWithConfigurationHandler( { (userInputTextField: UITextField!) -> Void in
            userInputTextField.placeholder = "Enter Password"
            userInputTextField.keyboardType = UIKeyboardType.Default
            userInputTextField.secureTextEntry = true
            inputTextField = userInputTextField
        })
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func updatePasswordTapped(sender: AnyObject) {
        var inputOldPassTextField: UITextField?
        var inputNewPassTextField: UITextField?
        
        let alertController = UIAlertController(title: "Are you sure you want to change your password?", message: "Please enter your old and new passwords.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action) -> Void in }))
        
        alertController.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            if let oldPasswordInput = inputOldPassTextField?.text {
                if let newPasswordInput = inputNewPassTextField?.text {
                    
                    UserController.changePasswordForUser(UserController.sharedController.currentUser!, oldPassword: oldPasswordInput, newPassword: newPasswordInput) { (error) -> Void in
                        if let error = error {
                            ErrorHandling.defaultErrorHandler(error, title: "\(error.localizedDescription)")
                        } else {
                            let successAlertController = UIAlertController(title: "Success!", message: "Your password has been changed.", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            successAlertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            }))
                            
                            self.presentViewController(successAlertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }))
        
        alertController.addTextFieldWithConfigurationHandler { (userInputOldPass: UITextField!) -> Void in
            userInputOldPass.placeholder = "Enter Old Password"
            userInputOldPass.keyboardType = UIKeyboardType.Default
            userInputOldPass.secureTextEntry = true
            inputOldPassTextField = userInputOldPass
        }
        alertController.addTextFieldWithConfigurationHandler { (userInputNewPass: UITextField!) -> Void in
            userInputNewPass.placeholder = "Enter New Password"
            userInputNewPass.keyboardType = UIKeyboardType.Default
            userInputNewPass.secureTextEntry = true
            inputNewPassTextField = userInputNewPass
        }
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func logoutTapped(sender: AnyObject) {
        FirebaseController.base.unauth()
        UserController.sharedController.currentUser = nil
        self.performSegueWithIdentifier("fromSettings", sender: nil)
    }
    
    
    @IBAction func updatePhotoTapped(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let dispatchGroup = dispatch_group_create()
        dispatch_group_enter(dispatchGroup)
        
        let photoChoiceAlert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            photoChoiceAlert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (_) -> Void in
                imagePicker.sourceType = .PhotoLibrary
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            
            photoChoiceAlert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (_) -> Void in
                imagePicker.sourceType = .Camera
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        
        photoChoiceAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(photoChoiceAlert, animated: true, completion: nil)
        
        dispatch_group_leave(dispatchGroup)
    }
    
    
    
    
    //MARK: - Image Picker Controller Delegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let identifier = UserController.sharedController.currentUser?.identifier {
            
            self.profilePhoto = info[UIImagePickerControllerOriginalImage] as? UIImage
            self.updateProfilePhotoButton.setBackgroundImage(self.profilePhoto, forState: .Normal)
            self.updateProfilePhotoButton.imageView?.contentMode = .ScaleToFill
            self.updateProfilePhotoButton.setTitle(nil, forState: .Normal)
            
            let successAlertController = UIAlertController(title: "Update Photo?", message: "Press Ok or Cancel.", preferredStyle: UIAlertControllerStyle.Alert)
            
            successAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                self.updateViewForMode(ViewMode.defaultView)
                
            }))
            
            successAlertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                ImageController.updateProfilePhoto(identifier, image: self.profilePhoto!, completion: { (success, error) -> Void in
                    
                    if success == true {
                        let successAlertController = UIAlertController(title: "Success!", message: "Photo updated.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        successAlertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            self.updateViewForMode(ViewMode.defaultView)
                        }))
                        self.presentViewController(successAlertController, animated: true, completion: nil)
                    } else {
                        ErrorHandling.defaultErrorHandler(error, title: "\(error!.localizedDescription)")
                    }
                })
            }))
            self.presentViewController(successAlertController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromSettings" {
            if let destinationController = segue.destinationViewController as? LoginViewController {
                _ = destinationController.view
                
            }
        }
    }
    
    
    // MARK: viewDid Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let pubGreen = colorWithHexString("6AFF63").CGColor
//        updateProfilePhotoButton.layer.borderColor = pubGreen
        updateProfilePhotoButton.layer.borderWidth = 1.0
        updateProfilePhotoButton.layer.cornerRadius = updateProfilePhotoButton.frame.size.width/2
        
        if let identifier = UserController.sharedController.currentUser?.identifier {
            
            ImageController.profilePhotoForIdentifier(identifier) { (photoUrl) -> Void in
                
                if let url = photoUrl {
                    ImageController.fetchImageAtUrl(url, completion: { (image) -> () in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.updateProfilePhotoButton.setBackgroundImage(image, forState: .Normal)
                            self.updateProfilePhotoButton.titleLabel?.text = ""
                            self.updateProfilePhotoButton.imageView?.contentMode = .ScaleToFill
                        })
                    })
                }
            }
            
        } else {
            print("no photo identifier")
        }
        
        self.updateViewForMode(ViewMode.defaultView)
        
        //textField delegate
        self.usernameTextField.delegate = self
        self.emailTextField.delegate = self
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        BarController.sharedController.currentBar = nil
    }
    
    
    
    // MARK: UI Helpers
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}
