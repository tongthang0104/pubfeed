//
//  NewPostTableTableViewController.swift
//  PubFeed
//
//  Created by Mike Gilroy on 06/01/2016.
//  Copyright © 2016 Mike Gilroy. All rights reserved.
//


import UIKit

class NewPostTableTableViewController: UITableViewController, UITextViewDelegate {

    let emojiMenu = ["☠", "💃", "🙈", "🍴", "😈", "🔥",
                     "🍼", "🍑", "🍆", "👴🏼", "💩", "🎸",
                    "🐌", "🌈", "⚽️", "🎉", "🎤", "🦄"]

    // MARK: Properties
    
    var selectedEmoji: String?
    var selectedPhoto: UIImage?
    var selectedButton: UIButton?
    var remainingChars: Int {
        get {
            return (140 - self.textView.text.characters.count)
        }
    }
    var placeholderText: String {
        get {
            if let bar = BarController.sharedController.currentBar {
                return " What's happening at \(bar.name)?"
            } else {
                return " What's happening here?"
            }
        }
    }

    // MARK: Outlets
    
    @IBOutlet weak var barCell: UITableViewCell!
    
    @IBOutlet weak var barLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!

    @IBOutlet var emojiButton: [UIButton]!
    
    @IBOutlet weak var emojiStackCell: UITableViewCell!
    
    @IBOutlet weak var emojiStack: UIStackView!
    
    @IBOutlet weak var barCellContent: UIView!
    
    @IBOutlet weak var charCountLabel: UILabel!
    
    @IBOutlet weak var placeholderLabel: UILabel!
    
    // MARK: Actions
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindToTabBar", sender: nil)
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        guard let bar = BarController.sharedController.currentBar else {
            animateView(barCellContent)
            return
        }
        guard let emojis = self.selectedEmoji else {
            animateView(emojiStack)
            return
        }
        guard self.remainingChars > 0 else {
            animateView(textView)
            animateView(charCountLabel)
            return
        }
        if let user = UserController.sharedController.currentUser {
            if let location = bar.location {
                PostController.createPost(location, emojis: emojis, text: self.textView.text, photo: selectedPhoto, bar: bar, user: user, completion: { (post, error) -> Void in
                    if let _ = error {
                        print("Error creating post")
                    } else {
                        self.performSegueWithIdentifier("unwindToTabBar", sender: nil)
                    }
                })
            } else {
                print("selected bar has no location")
            }
        } else {
            print("current user is nil")
        }
    }
    
    @IBAction func emojiTapped(sender: UIButton) {
        if selectedButton != nil {
            selectedButton!.alpha = CGFloat(0.35)
        }
        selectedEmoji = emojiMenu[sender.tag]
        selectedButton = sender
        sender.alpha = CGFloat(1.0)
    }
    
    
    // MARK: viewDid Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barTapRecognizer = UITapGestureRecognizer(target: self, action: "selectPub")
        barCell.addGestureRecognizer(barTapRecognizer)
        textView.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        view.addGestureRecognizer(tapRecognizer)
        for button in emojiButton {
            button.setBackgroundImage(UIImage(named: emojiMenu[button.tag]), forState: .Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if let currentBar = BarController.sharedController.currentBar {
            self.barLabel.text = currentBar.name
            self.barLabel.textColor = UIColor.blackColor()
        }
        if remainingChars < 140 {
            placeholderLabel.hidden = true
        } else {
            placeholderLabel.hidden = false
        }
        placeholderLabel.text = placeholderText
    }
    
    // MARK: UITextView Delegate
    
    func textViewDidChange(textView: UITextView) {
        charCountLabel.text = String(self.remainingChars)
        if self.remainingChars < 0 {
            charCountLabel.textColor = UIColor.redColor()
        }
        if self.remainingChars < 140 {
            placeholderLabel.hidden = true
        } else {
            placeholderLabel.hidden = false
        }
    }
    
    // MARK: TableView Delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        } else if indexPath.row == 1 {
            let width = emojiStackCell.frame.width - 16
            let height = width/6
            return CGFloat((height * 3) + 15)
        } else if indexPath.row == 2 {
            return emojiStackCell.frame.height * 2/3
        } else {
            return 0
        }
    }

    
    // MARK: Helper Functions
    
    func animateView(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(view.center.x - 10, view.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(view.center.x + 10, view.center.y))
        view.layer.addAnimation(animation, forKey: "position")
        
    }
    
    func hideKeyboard() {
        textView.resignFirstResponder()
    }
    
    func selectPub() {
        self.performSegueWithIdentifier("selectBar", sender: nil)
    }
    
    // MARK: Navigation
    @IBAction func unwindToNewPost(segue: UIStoryboardSegue) {
    }

    

}


