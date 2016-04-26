//
//  ChangePassViewController.swift
//  WhereMyChild
//
//  Created by Phantom on 02/04/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import UIKit

class ChangePassViewController: UIViewController {
    static let storyboardID = "ChangePassViewController"
    var email: String?
    var oldPass: String?
    
    let ref = Firebase(url:"https://mycargodriver.firebaseio.com")
    
    @IBOutlet weak var passTextField: UITextField!
    
    @IBAction func changePass(sender: AnyObject) {
        ref.changePasswordForUser(email!, fromOld: oldPass,
                                  toNew: passTextField.text!, withCompletionBlock: { error in
                                    if error != nil {
                                        let alert = UIAlertController(title: "Ошибка", message: "Некорректный пароль", preferredStyle: UIAlertControllerStyle.Alert)
                                        
                                        alert.addAction(UIAlertAction(title: "Ввести другой пароль", style: UIAlertActionStyle.Default,handler: nil))
                                        
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    } else {
                                        let alert = UIAlertController(title: nil, message: "Пароль изменен", preferredStyle: UIAlertControllerStyle.Alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                                            self.showMainViewAnimated(true)
                                        }))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showMainViewAnimated(animated: Bool) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(MainViewController.storyboardID)
        self.navigationController?.pushViewController(vc!, animated: animated)
    }
}
