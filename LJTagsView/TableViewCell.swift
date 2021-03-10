//
//  TableViewCell.swift
//  LJTagsView
//
//  Created by IMS_Mac on 2021/3/8.
//

import UIKit

class TableViewCell: UITableViewCell,LJTagsViewProtocol {
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.tagsView.reloadData()
//    }
    
    var model: UIModel? {
        didSet {
            titleLabel.text = model?.title
            tagsView.dataSource = model?.list ?? []
            self.tagsView.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = UILabel()
    lazy var tagsView: LJTagsView = LJTagsView()
    lazy var bgView: UIView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        print(self.contentView.frame.size.width)
        /**  必须给content width 值，否则会获取320*/
        self.contentView.frame.size.width = UIScreen.main.bounds.width
        print(self.contentView.frame.size.width)
        
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .black
        titleLabel.text = "title"
        self.contentView .addSubview(titleLabel);
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(10)
        }

        bgView.backgroundColor = .white
        bgView.layer.borderWidth = 0.5
        bgView.layer.borderColor = UIColor.gray.cgColor
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 4
        self.contentView .addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        tagsView.tagsViewDelegate = self
        tagsView.tagsViewContentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tagsView.tagsViewMinHeight = 40
        bgView.addSubview(tagsView)
        tagsView.snp.makeConstraints { (make) in
            make.top.right.left.bottom.equalToSuperview()
        }
    }
    
    func tagsViewUpdatePropertyModel(_ tagsView: LJTagsView, text: String, index: NSInteger) -> TagsPropertyModel {
        let propertyModel = TagsPropertyModel()
        propertyModel.contentPadding = 10
        propertyModel.imageAlignmentMode = .imageAlignmentLeft
//        propertyModel.contentView.backgroundColor = UIColor (red:  CGFloat (arc4random()%256)/255.0, green:  CGFloat (arc4random()%256)/255.0, blue:  CGFloat (arc4random()%256)/255.0, alpha: 1.0)
        propertyModel.contentView.backgroundColor = .lightGray
        propertyModel.contentView.layer.masksToBounds = true
        propertyModel.contentView.layer.cornerRadius = 4
        propertyModel.imageView.image = UIImage(named: "search_revoke")
        propertyModel.imageView.frame.size = CGSize(width:16, height: 16)
        propertyModel.titleLabel.textColor = .white
        return propertyModel
    }

    func tagsViewTapAction(_ tagsView: LJTagsView, text: String, index: NSInteger) {
        print("text = \(text) , index = \(index)")
        model?.list?.remove(at: index)
        tagsView.dataSource.remove(at: index)
        tagsView.reloadData()
    
        let tab:UITableView = self.superview as! UITableView
        tab.reloadData()
    }
}
