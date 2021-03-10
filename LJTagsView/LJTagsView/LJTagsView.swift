//
//  LJTagsView.swift
//  LJTagsView
//
//  Created by IMS_Mac on 2021/3/3.
//

import UIKit

/// LJTagsViewProtocol
@objc public protocol LJTagsViewProtocol : NSObjectProtocol {
    func tagsViewUpdatePropertyModel(_ tagsView: LJTagsView, text: String,index: NSInteger) -> TagsPropertyModel
    @objc optional func tagsViewUpdateHeight(_ tagsView: LJTagsView, sumHeight: CGFloat) -> Void
    @objc optional func tagsViewTapAction(_ tagsView: LJTagsView, text: String,index: NSInteger) -> Void
}

public class LJTagsView: UIView {
    
    public enum tagsViewScrollDirection {
        case vertical // 垂直
        case horizontal // 水平
    }
    
    /** 数据源*/
    public var dataSource: [String] = [] {
        didSet { config(oldValues: oldValue) }
    }
    /** 标签行间距 default is 10*/
    public var minimumLineSpacing: CGFloat = 10.0
    /** 标签的间距 default is 10*/
    public var minimumInteritemSpacing: CGFloat = 10.0
    /** tagsSupView的边距 default is top:0,letf:0,bottom:0,right:0*/
    public var tagsViewContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    /** tagsView 宽度 default  is 屏幕宽度  */
    private var tagsViewWidth = UIScreen.main.bounds.width
    /** tagsView 最小高度 default  is 0.0  */
    public var tagsViewMinHeight: CGFloat = 0.0 {
        didSet {
            // 限制条件
            tagsViewMinHeight = tagsViewMinHeight > tagsViewMaxHeight ? tagsViewMaxHeight : tagsViewMinHeight
        }
    }
    /** tagsView 最大高度 default  is   MAXFLOAT；当contentSize 大于tagsViewMaxHeight ，则会滚动；scrollDirection == horizontal时，这个属性失效*/
    public var tagsViewMaxHeight: CGFloat = CGFloat(MAXFLOAT) {
        didSet {
            // 限制条件
            tagsViewMaxHeight = tagsViewMaxHeight < tagsViewMinHeight ? tagsViewMinHeight : tagsViewMaxHeight
        }
    }
    /** tagsView 滚动方向 default  is   Vertical*/
    public var scrollDirection : tagsViewScrollDirection = .vertical
    
    public weak var tagsViewDelegate : LJTagsViewProtocol?
    
    /** 记录*/
    private var dealDataSource: [TagsPropertyModel] = [TagsPropertyModel]()
    
    private var scrollView = UIScrollView()
    
    private var contentSize = CGSize.zero
    
    public override init(frame:CGRect) {
        super.init(frame: frame)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
//        translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: -- setup数据
extension LJTagsView {
    
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//        reloadData()
//    }
       
    public func reloadData() -> Void {
        
        layoutIfNeeded()
        tagsViewWidth = frame.width
        
        var tagX: CGFloat = tagsViewContentInset.left
        var tagY: CGFloat = tagsViewContentInset.top
        var tagW: CGFloat = 0.0
        var tagH: CGFloat = 0.0
        
        var labelW: CGFloat = 0.0
        var labelH: CGFloat = 0.0
        var LableY: CGFloat = 0.0
        var imageY: CGFloat = 0.0
        
        var nextTagW: CGFloat = 0.0 // 下一个tag的宽度
        
        for (index,propertyModel) in dealDataSource.enumerated() {
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(contentViewTapAction(gestureRecongizer:)))
            propertyModel.contentView.tag = index
            propertyModel.contentView.addGestureRecognizer(tap)
            
            tagW = tagWidth(propertyModel)
            
            switch scrollDirection {
            case .vertical:
                
                if tagW > tagsViewWidth - tagsViewContentInset.left - tagsViewContentInset.right {
                    tagW = tagsViewWidth - tagsViewContentInset.left - tagsViewContentInset.right
                }
                
                labelW = tagW - (propertyModel.contentInset.left + propertyModel.contentInset.right + propertyModel.tagContentPadding + propertyModel.imageWidth)
                
                labelH = tagHeight(propertyModel, width: labelW)
                
                tagH = labelH + propertyModel.contentInset.top + propertyModel.contentInset.bottom
                
                tagH = tagH < propertyModel.minHeight ? propertyModel.minHeight : tagH
                
                tagH = tagH < propertyModel.imageHeight ? propertyModel.imageHeight : tagH
                
            case .horizontal:
                
                labelW = tagW - (propertyModel.contentInset.left + propertyModel.contentInset.right + propertyModel.tagContentPadding + propertyModel.imageWidth)
                labelH = tagHeight(propertyModel, width: labelW)
                tagH = labelH + propertyModel.contentInset.top + propertyModel.contentInset.bottom
                tagH = tagH < propertyModel.minHeight ? propertyModel.minHeight : tagH
                
            }
            
            LableY = (tagH - labelH) * 0.5
            
            imageY = (tagH - propertyModel.imageHeight) * 0.5
            
            propertyModel.contentView.frame = CGRect(x: tagX, y: tagY, width: tagW, height: tagH)
            
            switch propertyModel.imageAlignmentMode {
            case .imageAlignmentLeft:
                propertyModel.imageView.frame = CGRect(x: propertyModel.contentInset.left, y: imageY, width: propertyModel.imageWidth, height: propertyModel.imageHeight)
                propertyModel.titleLabel.frame = CGRect(x:  propertyModel.imageView.frame.maxX + propertyModel.tagContentPadding, y: LableY, width: labelW, height: labelH)
            case .imageAlignmentRight:
                propertyModel.titleLabel.frame = CGRect(x: propertyModel.contentInset.left, y: LableY, width: labelW, height: labelH)
                propertyModel.imageView.frame = CGRect(x: propertyModel.titleLabel.frame.maxX + propertyModel.tagContentPadding, y: imageY, width: propertyModel.imageWidth, height: propertyModel.imageHeight)
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
                    tagX = tagsViewContentInset.left
                    let lastObjFrame = propertyModel.contentView.frame
                    tagY = lastObjFrame.maxY + minimumLineSpacing
                }else {
                    tagX = nextTagX
                }
            case .horizontal:
                tagX = nextTagX
            }
        }
        
        var sumHeight = tagsViewMinHeight
        var scrollContentSize = CGSize.zero
        var viewContentSize = CGSize(width: tagsViewWidth, height: sumHeight)
        switch scrollDirection {
        case .vertical:
        
            if dealDataSource.count != 0 {
                let lastPropertyModel = dealDataSource.last
                sumHeight = lastPropertyModel!.contentView.frame.maxY + tagsViewContentInset.bottom
                scrollContentSize = CGSize(width: tagsViewWidth, height: sumHeight)
                sumHeight = sumHeight > tagsViewMaxHeight ? tagsViewMaxHeight : sumHeight
                viewContentSize = CGSize(width: tagsViewWidth, height: sumHeight)
            }
        case .horizontal:
            
            if dealDataSource.count != 0 {
                let lastPropertyModel = dealDataSource.last
                let sumWidth = lastPropertyModel!.contentView.frame.maxX + tagsViewContentInset.right
                sumHeight = tagH + tagsViewContentInset.bottom + tagsViewContentInset.top
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
        
        if let d = tagsViewDelegate {
            d.tagsViewUpdateHeight?(self, sumHeight: sumHeight)
        }
    }
    
    public override var intrinsicContentSize: CGSize {
       return contentSize
    }
}

  //MARK: -- private
extension LJTagsView {
    
    private func config(oldValues: [String]) {
        
         dealDataSource.removeAll()
         scrollView.subviews.forEach {  $0.removeFromSuperview() }
         for (index, value) in dataSource.enumerated() {
             var propertyModel = TagsPropertyModel()
             if let d = tagsViewDelegate {
                 propertyModel = d.tagsViewUpdatePropertyModel(self, text: value, index: index)
             }
             propertyModel.titleLabel.text = value
             scrollView.addSubview(propertyModel.contentView)
             dealDataSource.append(propertyModel)
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
        let size = model.titleLabel.text?.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options:[.usesLineFragmentOrigin,.usesFontLeading,.truncatesLastVisibleLine], attributes: [.font : model.titleLabel.font!], context: nil)
        return ceil(size?.height ?? 0.0)
    }
}

//MARK: -- action
extension LJTagsView {
    @objc func contentViewTapAction(gestureRecongizer: UIGestureRecognizer) {
        let int = gestureRecongizer.view?.tag ?? 0
        if let d = tagsViewDelegate {
            d.tagsViewTapAction?(self, text: dataSource[int], index: int)
        }
    }
}

//MARK: -- 设置每个tag的属性
public class TagsPropertyModel: NSObject {
    
    public enum TagImageViewAlignmentMode {
        case imageAlignmentRight
        case imageAlignmentLeft
    }
//    var selectContentBgColor: UIColor = .clear
//    var normalContentBgColor: UIColor = .clear {
//        didSet {
//            contentView.backgroundColor = normalContentBgColor
//        }
//    }
//    var selectImage: UIImage? = nil
//    var normalImage: UIImage? = nil {
//        didSet {
//            imageView.image = normalImage
//        }
//    }
//    var isSelected: Bool = false {
//        didSet {
//            if isSelected == true {
//                contentView.backgroundColor = selectContentBgColor
//                imageView.image = selectImage
//            }else {
//                contentView.backgroundColor = normalContentBgColor
//                imageView.image = normalImage
//            }
//        }
//    }
    
    /** image 和title 的间距 默认为8.0 ,设置image时生效*/
    public var contentPadding: CGFloat = 8.0
    /** 每个tag 最小高度 default is 30 */
    public var minHeight: CGFloat  { 30.0 }
    /** 每个tag的边距 default is top:5,letf:5,bottom:5,right:5*/
    public var contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    /** 装载view*/
    public var contentView = UIView()
    /** 标题*/
    public var titleLabel = UILabel()
    /** 图片*/
    public var imageView = UIImageView()
    /** 图片的位置*/
    public var imageAlignmentMode : TagImageViewAlignmentMode = .imageAlignmentRight
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
        super.init()
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        /** 每个tagtext 默认值*/
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        titleLabel.text = ""
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
    }
}

