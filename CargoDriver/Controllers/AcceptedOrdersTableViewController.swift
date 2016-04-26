//
//  AcceptedOrdersTableViewController.swift
//  CargoDriver
//
//  Created by Phantom on 23/04/16.
//  Copyright © 2016 Phantom. All rights reserved.
//

import UIKit

class AcceptedOrdersTableViewController: UITableViewController {
    let cellIdentifier = "AcceptedOrdersTableViewCell"
    let myRootRef = Firebase(url:"https://mycargodriver.firebaseio.com/orders")
    
    var user: Driver?
    var orders: [Order] = []
    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let currentDriver = user {
            myRootRef.queryOrderedByChild("acceptedUserEmail").queryEqualToValue(currentDriver.email)
                .observeEventType(.ChildAdded, withBlock: { snapshot in
                    guard let id = Int(snapshot.key!) else {
                        print("Error. Wrong order id")
                        return
                    }
                    
                    if let order = snapshot.value as? [String: String] {
                        let destination = order["destination"] ?? ""
                        let name = order["name"] ?? ""
                        let detail = order["detail"] ?? ""
                        let orderStatus = order["orderStatus"] ?? "0"

                        self.orders.append(Order(id: id, destination: destination, name: name, detail: detail, orderStatus: orderStatus))
                        self.tableView.reloadData()
                    }
            })
            
            myRootRef.queryOrderedByChild("acceptedUserEmail").queryEqualToValue(currentDriver.email)
                .observeEventType(.ChildRemoved, withBlock: { snapshot in
                    guard let id = Int(snapshot.key!) else {
                        print("Error. Wrong order id")
                        return
                    }
                    
                    if let orderIndex = self.orders.indexOf({$0.id == id}) {
                        self.orders.removeAtIndex(orderIndex)
                    }
                    
                    self.tableView.reloadData()
                })
            
            myRootRef.queryOrderedByChild("acceptedUserEmail").queryEqualToValue(currentDriver.email)
                .observeEventType(.ChildChanged, withBlock: { snapshot in
                    guard let id = Int(snapshot.key!) else {
                        print("Error. Wrong order id")
                        return
                    }
                    
                    if let order = snapshot.value as? [String: String] {
                        if let orderIndex = self.orders.indexOf({$0.id == id}) {
                            self.orders.removeAtIndex(orderIndex)
                        }
                        
                        let destination = order["destination"] ?? ""
                        let name = order["name"] ?? ""
                        let detail = order["detail"] ?? ""
                        let orderStatus = order["orderStatus"] ?? "0"
                        
                        self.orders.append(Order(id: id, destination: destination, name: name, detail: detail, orderStatus: orderStatus))
                        self.tableView.reloadData()
                    }
                })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let order = orders[indexPath.row]

        cell.textLabel?.text = order.fare.name
        cell.detailTextLabel?.text = order.destinationAdress
        
        if order.orderStatus == "1" {
            cell.backgroundColor = UIColor.grayColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let order = orders[indexPath.row]
        
        guard let vc = self.storyboard?.instantiateViewControllerWithIdentifier(ViewAcceptedOrderInfoViewController.storyboardId) as? ViewAcceptedOrderInfoViewController else {
            print("Error. No such VC")
            return
        }
        
        vc.order = order
        vc.user = user
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
