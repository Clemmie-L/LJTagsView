# LJTagsView
A lightweight label class, adaptive height, width.

## 使用场景

![image](https://github.com/Clemmie-L/LJTagsView/blob/main/image/ezgif-2-923de88307ee.gif)

## 使用方式

    pod 'LJTagsView'

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

    tagsView0.dataSource = ["Listing ID","Tower","Sole Agency Type","Have Keys","New Development","Tags","Big landlord","Street Address","Currency","Price per unit","Price per unit(Gross)","Price per unit(Saleable)","Size(Gross)","Size(Saleable)","Status","Register","Landlord","SSD","Agent","Floor Alias","Unit Alias","Unit Balcony","Tower Type","Building Age","Segment","Car Park","Is Coop","SPV","Pet Friendly","View Type","Property Type"]

    // 最后reload
    tagsView0.reloadData()

### delegate

    /** 设置每个tag的属性，包含UI ，对应的属性*/
    func tagsViewUpdatePropertyModel(_ tagsView: LJTagsView, item: TagsPropertyModel, index: NSInteger) {
        item.contentView.backgroundColor = UIColor.darkGray
        item.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        item.normalImage = UIImage(named: "select_not")
        item.selectIedImage = UIImage(named: "selected")
        item.imageSize = CGSize(width: 10, height: 10)
        item.imageAlignmentMode = .left
    }

    // 点击事情
    func tagsViewItemTapAction(_ tagsView: LJTagsView, item: TagsPropertyModel, index: NSInteger) {
    // 删除事件
        dataSource.remove(at: index)
        tagsView.dataSource.remove(at: index)
        tagsView.reloadData()
    }

    // 返回高度
    func tagsViewUpdateHeight(_ tagsView: LJTagsView, sumHeight: CGFloat) {

    // do something

    }

## 版本描述
### 1.0.0 初始版
### 1.0.1 优化optional protocol 的声明
### 1.0.2 添加showline 属性 ：实现展开和收合功能
### 1.0.3 添加[TagsPropertyModel] 数据源，方便初始化
### 1.0.4 修复每个tag 的minHeight 不统一造成布局错乱
### 1.0.6 适配OC；添加每个item的是否能点击属性:isEdit
### 1.0.7 添加默认资源
### 1.0.8 修复资源路径不对，导致无法加载资源
