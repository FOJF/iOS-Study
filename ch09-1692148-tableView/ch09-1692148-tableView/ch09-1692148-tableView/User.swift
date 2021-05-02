//
//  User.swift
//  ch09-1692148-tableView
//
//  Created by mac028 on 2021/04/29.
//

import Foundation

class User: NSObject {
    var id: String
    var name: String
    var passwd: String?
    
    init(id: String, name: String, passwd: String?) {
        self.id = id
        self.name = name
        self.passwd = passwd
        super.init()
    }
}

extension User {
    convenience init(random: Bool = false) {
        if random == false {
            self.init(id: "", name: "", passwd: "")
            return
        }
        let ids = ["01097604135", "01022384567", "01023456789"]
        let names = ["jmlee", "ymlee", "tmlee", "slkim", "yjkim"]
        
        var index = Int(arc4random_uniform(UInt32(ids.count)))
        let id = ids[index]
        
        index = Int(arc4random_uniform(UInt32(names.count)))
        let name = names[index]
        
        self.init(id: id, name: name, passwd: nil)
    }
}
