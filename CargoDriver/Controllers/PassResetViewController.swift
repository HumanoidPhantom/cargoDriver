//
//  PassResetViewController.swift
//  WhereMyChild
//
//  Created by Phantom on 02/04/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import UIKit

class PassResetViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    let ref = Firebase(url:"https://mycargodriver.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sendButtonClick(sender: AnyObject) {
        ref.resetPasswordForUser(emailTextField.text!, withCompletionBlock: { error in
            if error != nil {
                let alert = UIAlertController(title: "Ошибка", message: "Email неверный", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Попробовать еще раз", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: nil, message: "Сообщение отправленно", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
}
