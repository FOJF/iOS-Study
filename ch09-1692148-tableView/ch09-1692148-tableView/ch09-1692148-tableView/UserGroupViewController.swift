//
//  ViewController.swift
//  ch09-1692148-tableView
//
//  Created by mac028 on 2021/04/29.
//

import UIKit

class UserGroupViewController: UIViewController {
    
    @IBOutlet weak var userTableView: UITableView!
    var userGroup: UserGroup!
    
}

extension UserGroupViewController {
    @IBAction func editTable(_ sender: UIButton) {
        if userTableView.isEditing == true {
            userTableView.isEditing = false
            sender.setTitle("Edit", for: .normal)
        } else {
            userTableView.isEditing = true
            sender.setTitle("Edit", for: .normal)
        }
    }
}

extension UserGroupViewController {
    @IBAction func addUser(_ sender: UIButton) {
        let user = User(random: true)
        userGroup.addUser(user: user)
        let indexPath = IndexPath(row: userGroup.users.count-1, section: 0)
        userTableView.insertRows(at: [indexPath], with: .automatic)
    }
}

extension UserGroupViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userGroup = UserGroup()
        userGroup.testData()
        
        userTableView.dataSource = self
        userTableView.delegate = self
        //        userTableView.isEditing = true
    }
}

extension UserGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userGroup.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = UITableViewCell(style: .value1, reuseIdentifier: "UITableViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell")!
        
        let user = userGroup.users[indexPath.row]
        
        cell.textLabel!.text = user.id
        cell.detailTextLabel!.text = user.name
        cell.backgroundColor = .white
        
        if indexPath.row % 2 == 0 {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryView = UISwitch(frame: CGRect())
        }
        
        return cell
    }
}

extension UserGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)!.backgroundColor = .green
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)!.backgroundColor = .white
    }
}

extension UserGroupViewController {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let user = userGroup.users[indexPath.row]
            let title = "\(indexPath.row+1)번 줄에 있는 \(user.name) 삭제"
            let message = "진짜 지울거야?"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let deleteAction = UIAlertAction(title: "Sure", style: .destructive) {
                (action) in
                
                self.userGroup.removeUser(index: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            present(alertController, animated: true)
        }
    }
}

extension UserGroupViewController {
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let from = userGroup.users[sourceIndexPath.row]
        let to = userGroup.users[destinationIndexPath.row]
        userGroup.modifyUser(user: from, index: destinationIndexPath.row)
        userGroup.modifyUser(user: to, index: sourceIndexPath.row)
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
}
