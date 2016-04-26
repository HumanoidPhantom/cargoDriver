//
//  RegistrationViewController.swift
//  WhereMyChild
//
//  Created by Phantom on 25/03/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UITextFieldDelegate {
    
    static let storyboardID = "RegistrationViewController"
    let myRootRef = Firebase(url:"https://mycargodriver.firebaseio.com")
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var regButton: UIButton!
    @IBOutlet weak var loaderActivityIndicator: UIActivityIndicatorView!
    
    @IBAction func registerUser(sender: AnyObject) {
        self.showLoadingActivityView(true)
        
        let name = nameTextField.text!
        let email = emailTextField.text!
        let pass = passTextField.text!
        
        myRootRef.createUser(email, password: pass) { (error, result) in
            if error != nil {
                self.showLoadingActivityView(false)
                var message = ""
                switch error.code {
                case -5:
                    message = "Некорректный Email адрес"
                case -9:
                    message = "Данный Email адрес уже существует"
                default:
                    break
                }
                print(error)
                let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "Попробовать еще раз", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                let uid = result["uid"] as! String
                let usersRef = self.myRootRef.childByAppendingPath("users")
                let user = [
                    uid: [
                        "name": name,
                        "email": email,
                        "lat" : "",
                        "long" : "",
                    ]
                ]
                usersRef.setValue(user)
                
                self.myRootRef.authUser(email, password: pass) { (error, authData) in
                    if error != nil {
                        print(error)
                    } else {
                        _ = Driver(email: email, name: name)
                        self.showMainViewAnimated(true)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        checkValidData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        checkValidData()
        super.touchesBegan(touches, withEvent: event)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailTextField.becomeFirstResponder()
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
        regButton.enabled = !emailTextField.text!.isEmpty && !passTextField.text!.isEmpty && !nameTextField.text!.isEmpty
    }
    
    func showMainViewAnimated(animated: Bool) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(MainViewController.storyboardID)
        self.navigationController?.pushViewController(vc!, animated: animated)
    }
    
    func showLoadingActivityView(show: Bool) {
        regButton.hidden = show
        if show {
            loaderActivityIndicator.startAnimating()
        } else {
            loaderActivityIndicator.stopAnimating()
        }
    }
}
