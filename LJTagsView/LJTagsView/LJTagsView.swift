//
//  LJTagsView.swift
//  LJTagsView
//
//  Created by IMS_Mac on 2021/3/3.
//

import UIKit

/// LJTagsViewProtocol
@objc public protocol LJTagsViewProtocol: NSObjectProtocol {

    @objc optional func tagsViewUpdatePropertyModel(_ tagsView: LJTagsView, item: TagsPropertyModel,index: NSInteger) -> Void
    @objc optional func tagsViewUpdateHeight(_ tagsView: LJTagsView, sumHeight: CGFloat) -> Void
    @objc optional func tagsViewTapAction(_ tagsView: LJTagsView) -> Void
    @objc optional func tagsViewItemTapAction(_ tagsView: LJTagsView, item: TagsPropertyModel,index: NSInteger) -> Void
    
}

@objc public enum tagsViewScrollDirection: Int {
    case vertical = 0 // 垂直方向
    case horizontal = 1 // 水平方向
}

public class LJTagsView: UIView {
    
    /** 数据源*/
    @objc public var dataSource: [String] = [] {
        didSet {
            config()
        }
    }
    
    /** 数据源*/
    @objc public var modelDataSource: [TagsPropertyModel] = [] {
        didSet {
            config()
        }
    }
    
    /** 标签行间距 default is 10*/
    @objc public var minimumLineSpacing: CGFloat = 10.0
    
    /** 标签的间距 default is 10*/
    @objc public var minimumInteritemSpacing: CGFloat = 10.0
    
    /** tagsSupView的边距 default is top:0,letf:0,bottom:0,right:0*/
    @objc public var tagsViewContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    /** tagsView 最小高度 default  is 0.0  */
    @objc public var tagsViewMinHeight: CGFloat = 0.0 {
        didSet {
            // 限制条件
            tagsViewMinHeight = tagsViewMinHeight > tagsViewMaxHeight ? tagsViewMaxHeight : tagsViewMinHeight
        }
    }
    
    /** tagsView 最大高度 default  is   MAXFLOAT；当contentSize 大于tagsViewMaxHeight ，则会滚动；scrollDirection == horizontal时，这个属性失效*/
    @objc public var tagsViewMaxHeight: CGFloat = CGFloat(MAXFLOAT) {
        didSet {
            // 限制条件
            tagsViewMaxHeight = tagsViewMaxHeight < tagsViewMinHeight ? tagsViewMinHeight : tagsViewMaxHeight
        }
    }
    
    /** tagsView 滚动方向 default  is   Vertical*/
    @objc public var scrollDirection : tagsViewScrollDirection = .vertical
    
    /** 代理*/
    @objc open weak var tagsViewDelegate : LJTagsViewProtocol?
    
    /** 默认显示行数,0 为全部显示， 设置showLine: tagsViewScrollDirection = horizontal 无效*/
    @objc public var showLine: UInt = 0 {
        willSet {
            if newValue > 0 {
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(tagsViewTapAction))
                self.addGestureRecognizer(tap)
            }
        }
    }
    /** showLine 大于0 的时候 显示*/
    @objc public var arrowImageView: UIImageView = UIImageView.init(image: UIImage.init(named: "arrow")?.withRenderingMode(.alwaysOriginal))
    /** 是否选中*/
    
    @objc public var isSelect = false
    
    /** tagsView 宽度 default  is 屏幕宽度  */
    private var tagsViewWidth = UIScreen.main.bounds.width
    
    /** 记录*/
    private var dealDataSource: [TagsPropertyModel] = [TagsPropertyModel]()
    
    private var scrollView = UIScrollView()
    
    private var contentSize = CGSize.zero
    
    public override init(frame:CGRect) {
        super.init(frame: frame)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        arrowImageView.isHidden = true
        addSubview(scrollView)
        addSubview(arrowImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: -- setup数据
extension LJTagsView {
    
    @objc public func reloadData() -> Void {
        
        layoutIfNeeded()
        
        var tagX: CGFloat = tagsViewContentInset.left
        var tagY: CGFloat = tagsViewContentInset.top
        var tagW: CGFloat = 0.0
        var tagH: CGFloat = 0.0
        
        var labelW: CGFloat = 0.0
        var labelH: CGFloat = 0.0
        var LableY: CGFloat = 0.0
        var imageY: CGFloat = 0.0
        
        // 下一个tag的宽度
        var nextTagW: CGFloat = 0.0
        // 记录当前的行数，
        var currentLine: UInt = 1
        // 记录当前行数的全部数据
        var showLineDataSource: [TagsPropertyModel] = [TagsPropertyModel]()
        
        // 设置arroImageView
        arrowImageView.isHidden = !(dealDataSource.count > 0 && showLine > 0)
        if arrowImageView.isHidden {
            tagsViewWidth = frame.width
        }else {
            let arrowImageViewSize = arrowImageView.bounds.size
            arrowImageView.frame = CGRect(x: frame.width - tagsViewContentInset.right - arrowImageViewSize.width, y: tagsViewContentInset.top, width: arrowImageViewSize.width, height: arrowImageViewSize.height)
            tagsViewWidth = frame.width - arrowImageViewSize.width - 10
            let angle = isSelect == true ? Double.pi : 0.0
//            UIView.animate(withDuration: 0.3) { [unowned self] in
                arrowImageView.transform = CGAffineTransform.init(rotationAngle: CGFloat(angle))
//            }
        }
        
        for (index,propertyModel) in dealDataSource.enumerated() {
            
            if  tagsViewDelegate?.responds(to: #selector(tagsViewDelegate?.tagsViewItemTapAction(_:item:index:))) ?? false {
                let tap = UITapGestureRecognizer(target: self, action: #selector(contentViewTapAction(gestureRecongizer:)))
                propertyModel.contentView.addGestureRecognizer(tap)
                
            }
            
            propertyModel.contentView.tag = index
            
            tagW = tagWidth(propertyModel)
            
            switch scrollDirection {
            case .vertical:
                if tagW > tagsViewWidth - tagsViewContentInset.left - tagsViewContentInset.right {
                    tagW = tagsViewWidth - tagsViewContentInset.left - tagsViewContentInset.right
                }
            case .horizontal:
                break
            }
            
            labelW = tagW - (propertyModel.contentInset.left + propertyModel.contentInset.right + propertyModel.tagContentPadding + propertyModel.imageWidth)
            
            labelH = tagHeight(propertyModel, width: labelW)
            
            let contentH = labelH < propertyModel.imageHeight ? propertyModel.imageHeight : labelH
            
            tagH = contentH + propertyModel.contentInset.top + propertyModel.contentInset.bottom
            
            tagH = tagH < propertyModel.minHeight ? propertyModel.minHeight : tagH
            
            LableY = (tagH - labelH) * 0.5
            
            imageY = (tagH - propertyModel.imageHeight) * 0.5
            
            propertyModel.contentView.frame = CGRect(x: tagX, y: tagY, width: tagW, height: tagH)
            
            switch propertyModel.imageAlignmentMode {
            case .left:
                propertyModel.imageView.frame = CGRect(x: propertyModel.contentInset.left, y: imageY, width: propertyModel.imageWidth, height: propertyModel.imageHeight)
                propertyModel.titleLabel.frame = CGRect(x:  propertyModel.imageView.frame.maxX + propertyModel.tagContentPadding, y: LableY, width: labelW, height: labelH)
            case .right:
                propertyModel.titleLabel.frame = CGRect(x: propertyModel.contentInset.left, y: LableY, width: labelW, height: labelH)
                propertyModel.imageView.frame = CGRect(x: propertyModel.titleLabel.frame.maxX + propertyModel.tagContentPadding, y: imageY, width: propertyModel.imageWidth, height: propertyModel.imageHeight)
            }
            
            if showLine >= currentLine {
                showLineDataSource.append(propertyModel)
            }
            
            // 下一个tag，X,Y位置
            let nextTagX = tagX + tagW + minimumInteritemSpacing
            
            switch scrollDirection {
            case .vertical:
                // 获取下一个tag的宽度
                if index < dealDataSource.count - 1 {
                    let nextIndex = index + 1
                    let nextPropertyModel = dealDataSource[nextIndex]
                    nextTagW = tagWidth(nextPropertyModel)
                }
                if nextTagX + nextTagW + tagsViewContentInset.right > tagsViewWidth {
                    
                    currentLine = currentLine + 1
                    tagX = tagsViewContentInset.left
                    let subDealDataSource = dealDataSource[0...index]
                    let maxYModel = subDealDataSource.max { (m1, m2) -> Bool in
                       return m1.contentView.frame.maxY < m2.contentView.frame.maxY
                    }
                    let lastObjFrame = maxYModel!.contentView.frame
                    tagY = lastObjFrame.maxY + minimumLineSpacing
                }else {
                    tagX = nextTagX
                }
            case .horizontal:
                tagX = nextTagX
            }
        }
        
        // 最大收合数 等于 总数量 说明 不需要展开 隐藏箭头图标
        if showLineDataSource.count == dealDataSource.count {
            arrowImageView.isHidden = true
        }
       
        var sumHeight = tagsViewMinHeight
        var scrollContentSize = CGSize.zero
        var viewContentSize = CGSize(width: tagsViewWidth, height: sumHeight)
        
        switch scrollDirection {
        case .vertical:
            if dealDataSource.count != 0 {
               let resultDataSource = showLine > 0 && isSelect == false ? showLineDataSource :
                    dealDataSource
               let lastPropertyModel = filterMaxYModel(dataSource: resultDataSource, standardModel: resultDataSource.last!)
                sumHeight = lastPropertyModel.contentView.frame.maxY + tagsViewContentInset.bottom
                scrollContentSize = CGSize(width: tagsViewWidth, height: sumHeight)
                sumHeight = sumHeight > tagsViewMaxHeight ? tagsViewMaxHeight : sumHeight
                viewContentSize = CGSize(width: tagsViewWidth, height: sumHeight)
            }
        case .horizontal:
            if dealDataSource.count != 0 {
                let lastPropertyModel = filterMaxYModel(dataSource: dealDataSource, standardModel: dealDataSource.last!)
                let sumWidth = lastPropertyModel.contentView.frame.maxX + tagsViewContentInset.right
                sumHeight = lastPropertyModel.contentView.frame.maxY + tagsViewContentInset.bottom
                scrollContentSize = CGSize(width: sumWidth, height: sumHeight)
                viewContentSize = scrollContentSize
            }
        }
        
        frame.size.height = sumHeight
        scrollView.frame = CGRect(x: 0, y: 0, width: tagsViewWidth, height: sumHeight)
        scrollView.contentSize = scrollContentSize;
        
        if (!contentSize.equalTo(viewContentSize)) {
            contentSize = viewContentSize;
            // 通知外部IntrinsicContentSize失效
            invalidateIntrinsicContentSize()
        }
        
        tagsViewDelegate?.tagsViewUpdateHeight?(self, sumHeight: sumHeight)
        
    }
    
    public override var intrinsicContentSize: CGSize {
       return contentSize
    }
}

  //MARK: -- private
extension LJTagsView {
    
    private func config() {
        
         dealDataSource.removeAll()
         scrollView.subviews.forEach {  $0.removeFromSuperview() }
        
        if dataSource.count > 0 {
            for (index, value) in dataSource.enumerated() {
                let propertyModel = TagsPropertyModel()
                propertyModel.titleLabel.text = value
                if let d = tagsViewDelegate  {
                    d.tagsViewUpdatePropertyModel?(self, item: propertyModel, index: index)
                }
                scrollView.addSubview(propertyModel.contentView)
                dealDataSource.append(propertyModel)
            }
        }else {
            for (index,propertyModel) in modelDataSource.enumerated() {
                if let d = tagsViewDelegate  {
                    d.tagsViewUpdatePropertyModel?(self, item: propertyModel, index: index)
                }
                scrollView.addSubview(propertyModel.contentView)
                dealDataSource.append(propertyModel)
            }
        }
    
     }

    private func tagWidth(_ model: TagsPropertyModel) -> CGFloat {
        let w = ceil(sizeWidthText(model).width) + 0.5 + model.contentInset.left + model.contentInset.right + model.tagContentPadding + model.imageWidth
        return w
    }
    
    private func sizeWidthText(_ model: TagsPropertyModel) -> CGSize {
        return model.titleLabel.text?.size(withAttributes: [.font : model.titleLabel.font!]) ?? CGSize.zero
    }
    
    private func tagHeight(_ model: TagsPropertyModel, width: CGFloat) -> CGFloat {
        
//        if let attributedText = model.titleLabel.attributedText {
//            let size = attributedText.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin,.usesFontLeading,.truncatesLastVisibleLine], context: nil)
//            return ceil(size.height)
//        }
        
        if let text = model.titleLabel.text {
            let size = text.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options:[.usesLineFragmentOrigin,.usesFontLeading,.truncatesLastVisibleLine], attributes: [.font : model.titleLabel.font!], context: nil)
            return ceil(size.height)
        }
        return 0.0
    }
    
    // filter  - result return maxYModel
    private func filterMaxYModel(dataSource:[TagsPropertyModel],standardModel:TagsPropertyModel) -> TagsPropertyModel {
        let maxYModel = dataSource.filter { (m) -> Bool in
             m.contentView.frame.minY == standardModel.contentView.frame.minY
         }.max { (m1, m2) -> Bool in
             return m1.contentView.frame.maxY <= m2.contentView.frame.maxY
         }
        return maxYModel!
    }
}

//MARK: -- action
extension LJTagsView {
    
    @objc func contentViewTapAction(gestureRecongizer: UIGestureRecognizer) {
        let int = gestureRecongizer.view?.tag ?? 0
        if let d = tagsViewDelegate {
            let item = dealDataSource[int];
            item.isSelected = !item.isSelected
            d.tagsViewItemTapAction?(self, item: dealDataSource[int], index: int)
        }
    }
    
    @objc func tagsViewTapAction() {
        tagsViewDelegate?.tagsViewTapAction?(self)
    }
}

//MARK: -- 设置每个tag的属性
public class TagsPropertyModel: NSObject {
    
    @objc public enum TagImageViewAlignmentMode: Int {
        case right
        case left
    }
    
    /** 正常的图片*/
    @objc public var normalImage:UIImage? {
        willSet {
            if selectIedImage == nil { selectIedImage = newValue }
            if isSelected == false { imageView.image = newValue }
        }
    }
    /** 选中状态的图片*/
    @objc public var selectIedImage:UIImage? {
        willSet {
            if isSelected == true { imageView.image = newValue }
        }
    }
    /** 图片的大小*/
    @objc public var imageSize: CGSize {
        willSet {
            imageView.frame.size = newValue
        }
    }
    /** 是否选中*/
    @objc public var isSelected: Bool = false {
        willSet {
            imageView.image = newValue ? selectIedImage : normalImage
        }
    }
    
    /** 是否能操作*/
    @objc public var isEdit: Bool = true
    
    /** image 和title 的间距 默认为8.0 ,设置image时生效*/
    @objc public var contentPadding: CGFloat = 8.0
    
    /** 每个tag 最小高度 default is 0 */
    @objc public var minHeight: CGFloat = 0
    
    /** 每个tag的边距 default is top:5,letf:5,bottom:5,right:5*/
    @objc public var contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    /** 装载view*/
    @objc public var contentView = UIView()
    
    /** 标题*/
    @objc public var titleLabel = UILabel()
    
    /** 图片的位置*/
    @objc public var imageAlignmentMode : TagImageViewAlignmentMode = .right
    
    /** 图片*/
    @objc public var imageView = UIImageView()
    
    /** 默认为 image 大小*/
    fileprivate var imageWidth: CGFloat {
        guard let imageW = imageView.image?.size.width else {
            return 0.0
        }
        if imageView.frame != CGRect.zero, imageView.image != nil {
            return imageView.frame.width
        }
        return imageW
    }
    
    fileprivate var imageHeight: CGFloat {
        guard let imageH = imageView.image?.size.height else {
            return 0.0
        }
        if imageView.frame != CGRect.zero, imageView.image != nil {
            return imageView.frame.height
        }
        return imageH
    }
    
    fileprivate var tagContentPadding: CGFloat {
        get {
            return imageWidth > 0.0 ? contentPadding : 0.0
        }
    }
    
    public override init() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        /** 每个tagtext 默认值*/
        contentView.backgroundColor = .darkGray
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 5
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.text = ""
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        imageSize = CGSize.zero
        super.init()
    }
    
}

