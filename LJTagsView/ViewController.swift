//
//  ViewController.swift
//  LJTagsView
//
//  Created by IMS_Mac on 2021/3/10.
//

import UIKit
import SnapKit

class ViewController: UIViewController, LJTagsViewProtocol , UITextFieldDelegate {
    
    @IBOutlet weak var tabButton: UIButton!
    
    let tagsView0 = LJTagsView()
    let tagsView1 = LJTagsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tagsView0.backgroundColor = .brown
        tagsView0.tagsViewDelegate = self
        tagsView0.tagsViewContentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        tagsView0.tagsViewMinHeight = 40
//        tagsView0.scrollDirection = .horizontal
//        tagsView0.tagsViewMaxHeight = 300
        tagsView0.minimumLineSpacing = 30;
        tagsView0.minimumInteritemSpacing = 30;
        self.view.addSubview(tagsView0)
        tagsView0.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(150)
            make.left.equalToSuperview().offset(0)
            make.width.equalTo(414)
        }
        tagsView0.dataSource = ["11111231231231231231231231231231231231231231231231","21111123123123123123123123123123123123123123123131231噜啦啦啦啦噜啦啦啦啦噜啦啦啦啦噜啦啦啦啦噜啦啦啦啦","3","456","12345","555555","12345678","噜啦啦啦啦"]
        // 最后reload
        tagsView0.reloadData()
        
        let button = UIButton(frame: CGRect(x: 0, y: 400, width: 180, height: 40))
        button.setTitle("changeScrollDirection", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPink
        button.addTarget(self, action: #selector(buttonAction(button:)), for: .touchUpInside)
        self.view .addSubview(button)
        
        tagsView1.backgroundColor = .orange
        tagsView1.tagsViewDelegate = self
        tagsView1.tagsViewContentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tagsView1.frame = CGRect(x: 0, y: 450, width: 414, height: 0)
        tagsView1.tagsViewMaxHeight = 150
        tagsView1.dataSource = ["11111231231231231231231231231231231231231231231231","21111123123123123123123123123123123123123123123131231噜啦啦啦啦噜啦啦啦啦噜啦啦啦啦噜啦啦啦啦噜啦啦啦啦","3","456","12345","555555","12345678","噜啦啦啦啦","噜啦啦啦啦","噜啦啦啦啦","噜啦啦啦啦","噜啦啦啦啦","噜啦啦啦啦","噜啦啦啦啦","噜啦啦啦啦"]
        self.view.addSubview(tagsView1)
        tagsView1.reloadData()
        
    }
    
    func tagsViewUpdatePropertyModel(_ tagsView: LJTagsView, text: String, index: NSInteger) -> TagsPropertyModel {
        let propertyModel = TagsPropertyModel()
        propertyModel.contentPadding = 10
        propertyModel.imageAlignmentMode = .imageAlignmentLeft
        propertyModel.contentView.backgroundColor = UIColor (red:  CGFloat (arc4random()%256)/255.0, green:  CGFloat (arc4random()%256)/255.0, blue:  CGFloat (arc4random()%256)/255.0, alpha: 1.0)
        propertyModel.contentView.layer.masksToBounds = true
        propertyModel.contentView.layer.cornerRadius = 4
        if tagsView == tagsView0 {
            propertyModel.imageView.image = UIImage(named: "search_revoke")
        }
        propertyModel.imageView.frame.size = CGSize(width:16, height: 16)
//        propertyModel.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        propertyModel.titleLabel.textColor = .white
        return propertyModel
    }
    
    func tagsViewTapAction(_ tagsView: LJTagsView, text: String, index: NSInteger) {
        print("text = \(text) , index = \(index)")
        if tagsView == tagsView0 {
            tagsView.dataSource.remove(at: index)
            tagsView.reloadData()
        }
    }
    
    func tagsViewUpdateHeight(_ tagsView: LJTagsView, sumHeight: CGFloat) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        tagsView0.dataSource.append(textField.text!)
        tagsView0.reloadData()
        return true
    }
    
    @objc func buttonAction(button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            tagsView1.scrollDirection = .horizontal
        }else {
            tagsView1.scrollDirection = .vertical
        }
        tagsView1 .reloadData()
    }
    
    @IBAction func tabButtonAction(_ sender: Any) {
        self.present(TableViewController(), animated: true, completion: nil)
    }
}

