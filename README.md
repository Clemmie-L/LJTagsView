# LJTagsView
A lightweight label class, adaptive height, width.

## 使用场景


# 使用方式

    pod 'LJTagView'

### 初始化

    tagsView0.backgroundColor = .brown
    tagsView0.tagsViewDelegate = self
    tagsView0.tagsViewContentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    tagsView0.tagsViewMinHeight = 40
    tagsView0.scrollDirection = .horizontal
    tagsView0.tagsViewMaxHeight = 300
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

### delegate

    // 可以自定义每个tag的样式
    func tagsViewUpdatePropertyModel(_ tagsView: LJTagsView, text: String, index: NSInteger) -> TagsPropertyModel {

    let propertyModel = TagsPropertyModel()
    propertyModel.contentPadding = 10
    propertyModel.imageAlignmentMode = .imageAlignmentLeft
    propertyModel.contentView.backgroundColor = UIColor (red:  CGFloat (arc4random()%256)/255.0, green:  CGFloat (arc4random()%256)/255.0, blue:  CGFloat (arc4random()%256)/255.0, alpha: 1.0)
    propertyModel.contentView.layer.masksToBounds = true
    propertyModel.contentView.layer.cornerRadius = 4
    propertyModel.imageView.image = UIImage(named: "search_revoke")
    propertyModel.imageView.frame.size = CGSize(width:16, height: 16)
    propertyModel.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    propertyModel.titleLabel.textColor = .white
    return propertyModel
    
    }

    func tagsViewTapAction(_ tagsView: LJTagsView, text: String, index: NSInteger) {

    print("text = \(text) , index = \(index)")
    tagsView.dataSource.remove(at: index)
    tagsView.reloadData()
    
    }

    func tagsViewUpdateHeight(_ tagsView: LJTagsView, sumHeight: CGFloat) {

    // do something

    }
