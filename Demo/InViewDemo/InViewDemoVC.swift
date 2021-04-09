//
//  InViewDemoVC.swift
//  LJTagsView
//
//  Created by IMS_Mac on 2021/4/9.
//

import UIKit

let k_screenH = UIScreen.main.bounds.height
let k_screenW = UIScreen.main.bounds.width

class InViewDemoVC: UIViewController {
    
    enum TagsViewType: Int {
        case tagsViewFrameLayout = 0
        case tagsViewChangeScrollDirection
        case tagsViewShowLine
        case tagsViewManySelect
    }
    
    lazy var tagsView = LJTagsView()
    lazy var manySelectedResultTagsView = LJTagsView()
    
    var type: TagsViewType = TagsViewType.tagsViewFrameLayout
    
    var dataSource = ["Listing ID","Tower","Sole Agency Type","Have Keys","New Development","Tags","Big landlord","Street Address","Currency","Price per unit","Price per unit(Gross)","Price per unit(Saleable)","Size(Gross)","Size(Saleable)","Status","Register","Landlord","SSD","Agent","Floor Alias","Unit Alias","Unit Balcony","Tower Type","Building Age","Segment","Car Park","Is Coop","SPV","Pet Friendly","View Type","Property Type","Furnishing Type","Facing","Transportation","Features","Inventory","Tower Facilities","Property Facilities"]
    
//    var dataSource = ["Listing ID","Tower"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tagsView)
        tagsView.backgroundColor = .orange
        tagsView.tagsViewDelegate = self
        tagsView.tagsViewContentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tagsView.minimumLineSpacing = 10;
        tagsView.minimumInteritemSpacing = 10;
        tagsView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(80)
            make.left.right.equalToSuperview().offset(0)
        }
        tagsView.dataSource = dataSource
        // 最后reload
        
        switch type {
        case .tagsViewFrameLayout:
            setupTagsViewFrameLayout()
        case .tagsViewChangeScrollDirection:
            setupTagsViewChangeScrollDirection()
        case .tagsViewShowLine:
            setupTagsViewShowLine()
        case .tagsViewManySelect:
            setupTagsViewManySelect()
        }
    }
}

// tagsViewFrameLayout
extension InViewDemoVC {
    //
    func setupTagsViewFrameLayout() {
        tagsView.tagsViewMaxHeight = k_screenH - 20 - 40 - 80 - 80
        tagsView.reloadData()
        
        let button = UIButton(type: .custom)
        button.setTitle("添加", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .orange
        button.addTarget(self, action: #selector(addTagAction), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalTo(tagsView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
    }
    
    @objc func addTagAction() -> () {
        let item = dataSource[Int(arc4random()) % dataSource.count]
        dataSource.append(item)
        tagsView.dataSource.append(item)
        tagsView.reloadData()
    }
}
// tagsViewChangeScrollDirection
extension InViewDemoVC {
    func setupTagsViewChangeScrollDirection() {
        tagsView.tagsViewMinHeight = 40
        tagsView.scrollDirection = .vertical
        tagsView.tagsViewMaxHeight = 400
        tagsView.reloadData()
        
        
        let button = UIButton(type: .custom)
        button.setTitle("更改滚动方向", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .orange
        button.addTarget(self, action: #selector(changeScrollDirectionTagAction(button:)), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalTo(tagsView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
    }
    
    @objc func changeScrollDirectionTagAction(button: UIButton) {
        button.isSelected = !button.isSelected
       if button.isSelected {
            tagsView.scrollDirection = .horizontal
        }else {
            tagsView.scrollDirection = .vertical
        }
        tagsView.reloadData()
    }
}

// tagsViewShowLine
extension InViewDemoVC {
    
    func setupTagsViewShowLine() {
        tagsView.showLine = 2
        tagsView.reloadData()
    }
}

// tagsViewManySelect
extension InViewDemoVC {
    
    func setupTagsViewManySelect() {
        tagsView.reloadData()
        
        manySelectedResultTagsView.backgroundColor = .orange
        manySelectedResultTagsView.tagsViewDelegate = self
        manySelectedResultTagsView.tagsViewContentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        manySelectedResultTagsView.minimumLineSpacing = 10;
        manySelectedResultTagsView.minimumInteritemSpacing = 10;
        view.addSubview(manySelectedResultTagsView)
        manySelectedResultTagsView.snp.makeConstraints { (make) in
            make.top.equalTo(tagsView.snp.bottom).offset(10)
            make.right.left.equalToSuperview().offset(0)
        }
        
    }
}


extension InViewDemoVC: LJTagsViewProtocol {
    
    /** 设置每个tag的属性，包含UI ，对应的属性*/
    func tagsViewUpdatePropertyModel(_ tagsView: LJTagsView, text: String, index: NSInteger) -> TagsPropertyModel {
        let propertyModel = TagsPropertyModel()
        propertyModel.imageAlignmentMode = .imageAlignmentLeft
        switch type {
        case .tagsViewFrameLayout:
            propertyModel.normalImage = UIImage(named: "delete")
        case .tagsViewChangeScrollDirection:
            break
        case .tagsViewShowLine:
            break
        case .tagsViewManySelect where tagsView == self.tagsView:
            propertyModel.contentView.backgroundColor = UIColor.darkGray
            propertyModel.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            propertyModel.normalImage = UIImage(named: "select_not")
            propertyModel.selectIedImage = UIImage(named: "selected")
            break
        default:
            break
        }
        return propertyModel
    }
    
    func tagsViewItemTapAction(_ tagsView: LJTagsView, item: TagsPropertyModel, index: NSInteger) {
        
        switch type {
        case .tagsViewFrameLayout:
            dataSource.remove(at: index)
            tagsView.dataSource.remove(at: index)
        case .tagsViewManySelect:
            if item.isSelected == true {
                manySelectedResultTagsView.dataSource.append(item.titleLabel.text!)
            }else {
                manySelectedResultTagsView.dataSource.removeAll{ $0 == item.titleLabel.text! }
            }
            manySelectedResultTagsView.reloadData()
        default:
            break
        }
        tagsView.reloadData()
    }
    
    func tagsViewTapAction(_ tagsView: LJTagsView) {
        tagsView.isSelect = !tagsView.isSelect
        tagsView.reloadData()
    }
}
