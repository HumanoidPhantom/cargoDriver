//
//  ViewController.swift
//  WhereMyChild
//
//  Created by Phantom on 25/03/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    static let storyboardID = "ViewController"
    
    let myRootRef = Firebase(url:"https://mycargodriver.firebaseio.com")
    private var user: Driver?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var loaderActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonHolderView: UIView!
    
    @IBAction func loginButton(sender: AnyObject) {
        showLoadingActivityView(true)
        let email = emailTextField.text!
        let pass = passTextField.text!
        myRootRef.authUser(email, password: pass) { (error, authData) in
            if error != nil {
                print(error)
                self.showLoadingActivityView(false)
                
                let alert = UIAlertController(title: "Ошибка авторизации", message: "Email или пароль неверные", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Попробовать еще раз", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                self.user = Driver(email: email, name: "")
                let isTemp = authData.providerData["isTemporaryPassword"] as! Bool
                if isTemp {
                    self.showChangePassViewAnimated(true)
                } else {
                    self.showMainViewAnimated(true)
                }
                
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        showLoadingActivityView(false)
        enterButton.enabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passTextField.delegate = self
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let userDef = defaults.dictionaryForKey("user") as? [String: String], email = userDef["email"], name = userDef["name"] {
            self.user = Driver(email: email, name: name)
            showMainViewAnimated(false)

        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        passTextField.text = ""
        emailTextField.text = ""
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        checkValidData()
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passTextField.becomeFirstResponder()
        case passTextField:
            view.endEditing(true)
        default:
            break
        }
        
        checkValidData()
        textField.resignFirstResponder()
        return true
    }
    
    func checkValidData() {
        enterButton.enabled = !emailTextField.text!.isEmpty && !passTextField.text!.isEmpty
    }
    
    func showMainViewAnimated(animated: Bool) {
        guard let vc = self.storyboard?.instantiateViewControllerWithIdentifier(MainViewController.storyboardID) as? MainViewController else {
            print("Error. No such vc")
            return
        }
        
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: animated)
    }
    
    func showChangePassViewAnimated(animated: Bool) {
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(ChangePassViewController.storyboardID) as? ChangePassViewController {
            vc.oldPass = self.passTextField.text!
            vc.email = self.emailTextField.text!
            self.navigationController?.pushViewController(vc, animated: animated)
        }
    }
    
    func showLoadingActivityView(show: Bool) {
        buttonHolderView.hidden = show
        emailTextField.enabled = !show
        passTextField.enabled = !show
        if show {
            loaderActivityIndicator.startAnimating()
        } else {
            loaderActivityIndicator.stopAnimating()
        }
    }
}