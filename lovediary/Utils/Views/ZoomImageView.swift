//
//  ZoomImageView.swift
//  lovediary
//
//  Created by daovu on 08/04/2021.
//

import Foundation
import UIKit

open class ZoomImageView : UIScrollView, UIScrollViewDelegate {
    
    public enum ZoomMode {
        case fit
        case fill
    }
    
    // MARK: - Properties
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.allowsEdgeAntialiasing = true
        return imageView
    }()
    
    public var zoomMode: ZoomMode = .fit {
        didSet {
            updateImageView()
            scrollToCenter()
        }
    }
    
    open var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            let oldImage = imageView.image
            imageView.image = newValue
            
            if oldImage?.size != newValue?.size {
                oldSize = nil
                updateImageView()
            }
            scrollToCenter()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return imageView.intrinsicContentSize
    }
    
    private var oldSize: CGSize?
    
    // MARK: - Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public init(image: UIImage) {
        super.init(frame: CGRect.zero)
        self.image = image
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Functions
    open func scrollToCenter() {
        
        let centerOffset = CGPoint(
            x: contentSize.width > bounds.width ? (contentSize.width / 2) - (bounds.width / 2) : 0,
            y: contentSize.height > bounds.height ? (contentSize.height / 2) - (bounds.height / 2) : 0
        )
        
        contentOffset = centerOffset
    }
    
   private lazy var doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
    
    open func setup() {
        
        #if swift(>=3.2)
        if #available(iOS 11, *) {
            contentInsetAdjustmentBehavior = .never
        }
        #endif
        
        backgroundColor = UIColor.clear
        delegate = self
        imageView.contentMode = .scaleAspectFill
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        addSubview(imageView)
//        imageView.isUserInteractionEnabled = true
//        doubleTapGesture.numberOfTapsRequired = 2
//        imageView.addGestureRecognizer(doubleTapGesture)
    }
    
    func configWith(tap: UITapGestureRecognizer) {
//        tap.require(toFail: doubleTapGesture)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    open override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if imageView.image != nil && oldSize != bounds.size {
            
            updateImageView()
            oldSize = bounds.size
        }
        
        if imageView.frame.width <= bounds.width {
            imageView.center.x = bounds.width * 0.5
        }
        
        if imageView.frame.height <= bounds.height {
            imageView.center.y = bounds.height * 0.5
        }
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        updateImageView()
    }
    
    private func updateImageView() {
        
        func fitSize(aspectRatio: CGSize, boundingSize: CGSize) -> CGSize {
            
            let widthRatio = (boundingSize.width / aspectRatio.width)
            let heightRatio = (boundingSize.height / aspectRatio.height)
            
            var boundingSize = boundingSize
            
            if widthRatio < heightRatio {
                boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height
            }
            else if (heightRatio < widthRatio) {
                boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width
            }
            return CGSize(width: ceil(boundingSize.width), height: ceil(boundingSize.height))
        }
        
        func fillSize(aspectRatio: CGSize, minimumSize: CGSize) -> CGSize {
            let widthRatio = (minimumSize.width / aspectRatio.width)
            let heightRatio = (minimumSize.height / aspectRatio.height)
            
            var minimumSize = minimumSize
            
            if widthRatio > heightRatio {
                minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height
            }
            else if (heightRatio > widthRatio) {
                minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width
            }
            return CGSize(width: ceil(minimumSize.width), height: ceil(minimumSize.height))
        }
        
        guard let image = imageView.image else { return }
        
        var size: CGSize
        
        switch zoomMode {
        case .fit:
            size = fitSize(aspectRatio: image.size, boundingSize: bounds.size)
        case .fill:
            size = fillSize(aspectRatio: image.size, minimumSize: bounds.size)
        }
        
        size.height = round(size.height)
        size.width = round(size.width)
        
        zoomScale = 1
        maximumZoomScale = image.size.width / size.width
        imageView.bounds.size = size
        contentSize = size
        imageView.center = ZoomImageView.contentCenter(forBoundingSize: bounds.size, contentSize: contentSize)
    }
    
    @objc private func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
      
        if self.zoomScale == 1 {
            zoom(
                to: zoomRectFor(scale: 2, with: gestureRecognizer.location(in: gestureRecognizer.view)),
                animated: true
            )
        } else {
            setZoomScale(1, animated: true)
        }
    }
    
    // This function is borrowed from: https://stackoverflow.com/questions/3967971/how-to-zoom-in-out-photo-on-double-tap-in-the-iphone-wwdc-2010-104-photoscroll
    private func zoomRectFor(scale: CGFloat, with center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        if let imageV = self.viewForZooming(in: self) {
            zoomRect.size.height = imageV.frame.size.height / scale
            zoomRect.size.width  = imageV.frame.size.width  / scale
            let newCenter = imageV.convert(center, from: self)
            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0))
            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0))
        }
        return zoomRect
    }
    
    // MARK: - UIScrollViewDelegate
    @objc dynamic public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = ZoomImageView.contentCenter(forBoundingSize: bounds.size, contentSize: contentSize)
    }
    
    @objc dynamic public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    
    @objc dynamic public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }
    
    @objc dynamic public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @inline(__always)
    private static func contentCenter(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGPoint {
        
        /// When the zoom scale changes i.e. the image is zoomed in or out, the hypothetical center
        /// of content view changes too. But the default Apple implementation is keeping the last center
        /// value which doesn't make much sense. If the image ratio is not matching the screen
        /// ratio, there will be some empty space horizontaly or verticaly. This needs to be calculated
        /// so that we can get the correct new center value. When these are added, edges of contentView
        /// are aligned in realtime and always aligned with corners of scrollview.
        let horizontalOffest = (boundingSize.width > contentSize.width) ? ((boundingSize.width - contentSize.width) * 0.5): 0.0
        let verticalOffset = (boundingSize.height > contentSize.height) ? ((boundingSize.height - contentSize.height) * 0.5): 0.0
        
        return CGPoint(x: contentSize.width * 0.5 + horizontalOffest,  y: contentSize.height * 0.5 + verticalOffset)
    }
}

@objc public protocol ImageScrollViewDelegate: UIScrollViewDelegate {
    func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView)
}

open class ImageScrollView: UIScrollView {
    
    @objc public enum ScaleMode: Int {
        case aspectFill
        case aspectFit
        case widthFill
        case heightFill
    }
    
    @objc public enum Offset: Int {
        case begining
        case center
    }
    
    static let kZoomInFactorFromMinWhenDoubleTap: CGFloat = 2
    
    @objc open var imageContentMode: ScaleMode = .widthFill
    @objc open var initialOffset: Offset = .begining
    
    @objc public private(set) var zoomView: UIImageView? = nil
    
    @objc open weak var imageScrollViewDelegate: ImageScrollViewDelegate?

    var imageSize: CGSize = CGSize.zero
    private var pointToCenterAfterResize: CGPoint = CGPoint.zero
    private var scaleToRestoreAfterResize: CGFloat = 1.0
    open var maxScaleFromMinScale: CGFloat = 3.0
    
    override open var frame: CGRect {
        willSet {
            if frame.equalTo(newValue) == false && newValue.equalTo(CGRect.zero) == false && imageSize.equalTo(CGSize.zero) == false {
                prepareToResize()
            }
        }
        
        didSet {
            if frame.equalTo(oldValue) == false && frame.equalTo(CGRect.zero) == false && imageSize.equalTo(CGSize.zero) == false {
                recoverFromResizing()
            }
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initialize() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        decelerationRate = UIScrollView.DecelerationRate.fast
        delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ImageScrollView.changeOrientationNotification), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc public func adjustFrameToCenter() {
        
        guard let unwrappedZoomView = zoomView else {
            return
        }
        
        var frameToCenter = unwrappedZoomView.frame
        
        // center horizontally
        if frameToCenter.size.width < bounds.width {
            frameToCenter.origin.x = (bounds.width - frameToCenter.size.width) / 2
        }
        else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
        if frameToCenter.size.height < bounds.height {
            frameToCenter.origin.y = (bounds.height - frameToCenter.size.height) / 2
        }
        else {
            frameToCenter.origin.y = 0
        }
        
        unwrappedZoomView.frame = frameToCenter
    }
    
    private func prepareToResize() {
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        pointToCenterAfterResize = convert(boundsCenter, to: zoomView)
        
        scaleToRestoreAfterResize = zoomScale
        
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.
        if scaleToRestoreAfterResize <= minimumZoomScale + CGFloat(Float.ulpOfOne) {
            scaleToRestoreAfterResize = 0
        }
    }
    
    private func recoverFromResizing() {
        setMaxMinZoomScalesForCurrentBounds()
        
        // restore zoom scale, first making sure it is within the allowable range.
        let maxZoomScale = max(minimumZoomScale, scaleToRestoreAfterResize)
        zoomScale = min(maximumZoomScale, maxZoomScale)
        
        // restore center point, first making sure it is within the allowable range.
        
        // convert our desired center point back to our own coordinate space
        let boundsCenter = convert(pointToCenterAfterResize, to: zoomView)
        
        // calculate the content offset that would yield that center point
        var offset = CGPoint(x: boundsCenter.x - bounds.size.width/2.0, y: boundsCenter.y - bounds.size.height/2.0)
        
        // restore offset, adjusted to be within the allowable range
        let maxOffset = maximumContentOffset()
        let minOffset = minimumContentOffset()
        
        var realMaxOffset = min(maxOffset.x, offset.x)
        offset.x = max(minOffset.x, realMaxOffset)
        
        realMaxOffset = min(maxOffset.y, offset.y)
        offset.y = max(minOffset.y, realMaxOffset)
        
        contentOffset = offset
    }
    
    private func maximumContentOffset() -> CGPoint {
        return CGPoint(x: contentSize.width - bounds.width,y:contentSize.height - bounds.height)
    }
    
    private func minimumContentOffset() -> CGPoint {
        return CGPoint.zero
    }
    
    // MARK: - Set up
    
    open func setup() {
        var topSupperView = superview
        
        while topSupperView?.superview != nil {
            topSupperView = topSupperView?.superview
        }
        
        // Make sure views have already layout with precise frame
        topSupperView?.layoutIfNeeded()
        
        DispatchQueue.main.async {
            self.refresh()
        }
    }

    // MARK: - Display image
    
    private lazy var doubletapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageScrollView.doubleTapGestureRecognizer(_:)))
    
    @objc open func display(image: UIImage) {

        if let zoomView = zoomView {
            zoomView.removeFromSuperview()
        }
        
        zoomView = UIImageView(image: image)
        zoomView!.isUserInteractionEnabled = true
        addSubview(zoomView!)
        
        doubletapGestureRecognizer.numberOfTapsRequired = 2
        zoomView!.addGestureRecognizer(doubletapGestureRecognizer)
        configureImageForSize(image.size)
    }
    
    open func config(with guesture : UIGestureRecognizer) {
        guesture.require(toFail: doubletapGestureRecognizer)
    }
    
    private func configureImageForSize(_ size: CGSize) {
        imageSize = size
        contentSize = imageSize
        setMaxMinZoomScalesForCurrentBounds()
        zoomScale = minimumZoomScale
        
        switch initialOffset {
        case .begining:
            contentOffset =  CGPoint.zero
        case .center:
            let xOffset = contentSize.width < bounds.width ? 0 : (contentSize.width - bounds.width)/2
            let yOffset = contentSize.height < bounds.height ? 0 : (contentSize.height - bounds.height)/2

            switch imageContentMode {
            case .aspectFit:
                contentOffset =  CGPoint.zero
            case .aspectFill:
                contentOffset = CGPoint(x: xOffset, y: yOffset)
            case .heightFill:
                contentOffset = CGPoint(x: xOffset, y: 0)
            case .widthFill:
                contentOffset = CGPoint(x: 0, y: yOffset)
            }
        }
    }
    
    private func setMaxMinZoomScalesForCurrentBounds() {
        // calculate min/max zoomscale
        let xScale = bounds.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = bounds.height / imageSize.height   // the scale needed to perfectly fit the image height-wise
    
        var minScale: CGFloat = 1
        
        switch imageContentMode {
        case .aspectFill:
            minScale = max(xScale, yScale)
        case .aspectFit:
            minScale = min(xScale, yScale)
        case .widthFill:
            minScale = xScale
        case .heightFill:
            minScale = yScale
        }
        
        
        let maxScale = maxScaleFromMinScale*minScale
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if minScale > maxScale {
            minScale = maxScale
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale * 0.999 // the multiply factor to prevent user cannot scroll page while they use this control in UIPageViewController
    }
    
    // MARK: - Gesture
    
    @objc func doubleTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // zoom out if it bigger than the scale factor after double-tap scaling. Else, zoom in
        if zoomScale >= minimumZoomScale * ImageScrollView.kZoomInFactorFromMinWhenDoubleTap - 0.01 {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            let center = gestureRecognizer.location(in: gestureRecognizer.view)
            let zoomRect = zoomRectForScale(ImageScrollView.kZoomInFactorFromMinWhenDoubleTap * minimumZoomScale, center: center)
            zoom(to: zoomRect, animated: true)
        }
    }
    
    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        
        // the zoom rect is in the content view's coordinates.
        // at a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
        // as the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.height = frame.size.height / scale
        zoomRect.size.width  = frame.size.width  / scale
        
        // choose an origin so as to get the right center.
        zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
    open func refresh() {
        if let image = zoomView?.image {
            display(image: image)
        }
    }
    
    // MARK: - Actions
    
    @objc func changeOrientationNotification() {
        // A weird bug that frames are not update right after orientation changed. Need delay a little bit with async.
        DispatchQueue.main.async {
            self.configureImageForSize(self.imageSize)
            self.imageScrollViewDelegate?.imageScrollViewDidChangeOrientation(imageScrollView: self)
        }
    }
}

extension ImageScrollView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        imageScrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        imageScrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        imageScrollViewDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        imageScrollViewDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustFrameToCenter()
        imageScrollViewDelegate?.scrollViewDidZoom?(scrollView)
    }
    
}
