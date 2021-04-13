//
//  TableViewCell.swift
//  LJTagsView
//
//  Created by IMS_Mac on 2021/3/8.
//

import UIKit

class TableViewCell: UITableViewCell,LJTagsViewProtocol {
    
    var model: UIModel? {
        willSet {
            if let model = newValue {
                titleLabel.text = model.title
                tagsView.dataSource = model.list!
                tagsView.isSelect = model.isSelect
                self.tagsView.reloadData()
            }
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
        tagsView.showLine = 2
    }
    
    func tagsViewItemTapAction(_ tagsView: LJTagsView, item: TagsPropertyModel, index: NSInteger) {
        print("text = \(item.titleLabel.text!) , index = \(index)")
        model?.list?.remove(at: index)
        tagsView.dataSource.remove(at: index)
    
        let tab:UITableView = self.superview as! UITableView
        tab.reloadData()
        
    }
    
    func tagsViewTapAction(_ tagsView: LJTagsView) {
        let tab:UITableView = self.superview as! UITableView
        model?.isSelect = !(model?.isSelect)!
        tab.reloadData()
    }
}
