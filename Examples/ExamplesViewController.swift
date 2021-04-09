//
//  ExamplesViewController.swift
//  LJTagsView
//
//  Created by IMS_Mac on 2021/4/9.
//

import UIKit

class ExamplesViewController: UIViewController {
    
    var tabView:UITableView!
    lazy var dataSource = Array<[String]>()
    static let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()

        tabView = UITableView(frame: view.bounds, style: .grouped)
        tabView.delegate = self
        tabView.dataSource = self
        tabView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellId)
        view.addSubview(tabView)
        
        dataSource.append(["自适应高度","固定高度并可以改变方向","多行展开","多选"])
        dataSource.append(["tableView用例"])
    }
}

extension ExamplesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = dataSource[section]
        return section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tabView.dequeueReusableCell(withIdentifier: Self.cellId, for: indexPath)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = .systemFont(ofSize: 18)
        cell.textLabel?.text = dataSource[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "In-View"
        case 1:
            return "In-TableView"
        default:
            return ""
        }
    }
}

extension ExamplesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            jumpInViewDemoVC(row: indexPath.row)
        case 1:
            jumpTableView()
            break
        default:
            break
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func jumpInViewDemoVC(row: Int) {
        let inViewDemoVC = InViewDemoVC()
        if row == 0 { inViewDemoVC.type = .tagsViewFrameLayout }
        if row == 1 { inViewDemoVC.type = .tagsViewChangeScrollDirection }
        if row == 2 { inViewDemoVC.type = .tagsViewShowLine }
        if row == 3 { inViewDemoVC.type = .tagsViewManySelect }
     
        present(inViewDemoVC, animated: true, completion: nil)
    }
    
    func jumpTableView() {
        let vc = InTabViewVC()
        present(vc, animated: true, completion: nil)
    }
}
