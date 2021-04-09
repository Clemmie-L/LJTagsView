//
//  InTabViewVC.swift
//  LJTagsView
//
//  Created by IMS_Mac on 2021/4/9.
//

import UIKit

class UIModel {
    var title: String = ""
    var padding: CGFloat = 10.0
    var isSelect = false
    var list: [String]?
}

class InTabViewVC: UITableViewController {
    
    var list = Array<Any>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.tableView.estimatedRowHeight = 100
        self.tableView?.rowHeight = UITableView.automaticDimension
        for index in 0..<100 {
            let model = UIModel()
            model.title = "title + \(index)"
            model.padding = CGFloat(10 + Double(index)*10)
            model.list = ["index + \(index)","index + \(index)","index + \(index)","index + \(index)","index + \(index)","index + \(index)","index + \(index)","index + \(index)","index + \(index)","index + \(index)","index + \(index)"]
            list.append(model)
        }

        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
        
        cell.model = (list[indexPath.row] as! UIModel)

        return cell
    }
    
    
}





