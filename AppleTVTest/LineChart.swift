//
//  LineChart.swift
//  AppleTVTest
//
//  Created by Rolf Locher on 12/10/18.
//  Copyright © 2018 Rolf Locher. All rights reserved.
//

import UIKit


struct PointEntry {
    let value: Double
    let label: String
}

extension PointEntry: Comparable {
    static func <(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value < rhs.value
    }
    static func ==(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value == rhs.value
    }
}

class LineChart: UIView {
    
    
    
    
    
    /// gap between each point
    let lineGap: CGFloat = 2.3 //60.0
    
    /// preseved space at top of the chart
    let topSpace: CGFloat = 40.0
    
    /// preserved space at bottom of the chart to show labels along the Y axis
    let bottomSpace: CGFloat = 80.0 //40.0
    
    /// The top most horizontal line in the chart will be 10% higher than the highest value in the chart
    let topHorizontalLine: CGFloat = 110.0 / 100.0
    
    var isCurved: Bool = false
    
    /// Active or desactive animation on dots
    var animateDots: Bool = false
    
    /// Active or desactive dots
    var showDots: Bool = false
    
    /// Dot inner Radius
    var innerRadius: CGFloat = 8
    
    /// Dot outer Radius
    var outerRadius: CGFloat = 12
    
    var dataEntries: [PointEntry]? {
        didSet {
            DispatchQueue.main.async {
                self.setNeedsLayout()
            }
            
        }
    }
    
    private var dataPoints: [CGPoint]?
    
    
    
    /// Contains the main line which represents the data
    private let dataLayer: CALayer = CALayer()
    
    /// To show the gradient below the main line
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    /// Contains dataLayer and gradientLayer
    private let mainLayer: CALayer = CALayer()
    
    /// Contains mainLayer and label for each data entry
    private let scrollView: UIScrollView = UIScrollView()
    
    /// Contains horizontal lines
    private let gridLayer: CALayer = CALayer()
    
    var canFocusAway = true
    
    
    override var canBecomeFocused: Bool {
        return true
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.layer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor
            }, completion: nil)
            
        } else if context.previouslyFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.layer.backgroundColor = UIColor.clear.cgColor
            }, completion: nil)
        }
    }
    
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for item in presses {
            if item.type == .select {
                customSC.isHidden = !customSC.isHidden
                canFocusAway = !canFocusAway
                
            }
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for item in presses {
            if item.type == .select {
                print("presses ended")
                
            }
        }
    }
    
    
    
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        return self.canFocusAway
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipe(gesture:)))
//        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipe(gesture:)))
        
        
        
        setupView()
//        swipeRightRecognizer.direction = .right
//        self.addGestureRecognizer(swipeRightRecognizer)
//        self.scrollView.isUserInteractionEnabled = false
//        swipeLeftRecognizer.direction = .left
//        swipeLeftRecognizer.isEnabled = true
//        self.addGestureRecognizer(swipeLeftRecognizer)
        
//        respondToSwipe(gesture: swipeRightRecognizer)
//        respondToSwipe(gesture: swipeLeftRecognizer)
//        self.isUserInteractionEnabled = true
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    @objc public func changeColor (_ sender:UISegmentedControl!){
        print("yes")
    }
    
    @objc func respondToSwipe (gesture: UISwipeGestureRecognizer) -> Void{
        
        
        print("swipe tried to do something")
        if customSC.selectedSegmentIndex == 0 {
            customSC.selectedSegmentIndex = 1
        }
        else {
            customSC.selectedSegmentIndex = 0
        }
    }
    
    let customSC = UISegmentedControl(items: ["Line","Candle"])
    
    
    
    
   
    
    
    private func setupView() {
        
        
        
//        let items = ["Line", "Candle"]
//        let customSC = UISegmentedControl(items: items)
        customSC.isHidden = true
        customSC.selectedSegmentIndex = 0
        // Set up Frame and SegmentedControl
        customSC.frame = CGRect(x: 450, y: 300, width: 300, height: 100)
        // Style the Segmented Control
        customSC.layer.cornerRadius = 5.0  // Don't let background bleed
        customSC.backgroundColor = UIColor.black
        customSC.tintColor = UIColor.white
        // Add target action method
        customSC.addTarget(self, action: #selector(self.changeColor(_:)), for: .valueChanged)
        
        // Add this custom Segmented Control to our view
        self.addSubview(customSC)
        
        
        
        mainLayer.addSublayer(dataLayer)
        scrollView.layer.addSublayer(mainLayer)
        
        gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7).cgColor, UIColor.clear.cgColor]
        //scrollView.layer.addSublayer(gradientLayer)
        self.layer.addSublayer(gridLayer)
        self.layer.cornerRadius = 3.0
        self.addSubview(scrollView)
        //self.backgroundColor = #colorLiteral(red: 0, green: 0.3529411765, blue: 0.6156862745, alpha: 1)
        self.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:CGFloat(0.1))
    }
    private func convertDataEntriesToPoints(entries: [PointEntry]) -> [CGPoint] {
        if let max = entries.max()?.value,
            let min = entries.min()?.value {
            
            var result: [CGPoint] = []
            let minMaxRange: CGFloat = CGFloat(max - min) * topHorizontalLine
            
            print(CGFloat(max))
            print(CGFloat(min))
            print(minMaxRange)
            
            print(CGFloat(entries[0].value))
            
            for i in 0..<entries.count {
                let height = dataLayer.frame.height * (1 - ((CGFloat(entries[i].value) - CGFloat(min)) / minMaxRange))
                let point = CGPoint(x: CGFloat(i)*lineGap + 40, y: height)
                result.append(point)
            }
            return result
        }
        return []
    }
    private func clean() {
        mainLayer.sublayers?.forEach({
            if $0 is CATextLayer {
                $0.removeFromSuperlayer()
            }
        })
        dataLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        gridLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
    private func drawChart() {
        if let dataPoints = dataPoints,
            dataPoints.count > 0,
            let path = createPath() {
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }
    private func createPath() -> UIBezierPath? {
        guard let dataPoints = dataPoints, dataPoints.count > 0 else {
            return nil
        }
        let path = UIBezierPath()
        path.move(to: dataPoints[0])
        
        for i in 1..<dataPoints.count {
            path.addLine(to: dataPoints[i])
        }
        return path
    }
    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        if let dataEntries = dataEntries {
            scrollView.contentSize = CGSize(width: CGFloat(dataEntries.count) * lineGap, height: self.frame.size.height)
            mainLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(dataEntries.count) * lineGap, height: self.frame.size.height)
            dataLayer.frame = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            //gradientLayer.frame = dataLayer.frame
            dataPoints = convertDataEntriesToPoints(entries: dataEntries)
            gridLayer.frame = CGRect(x: 0, y: topSpace, width: self.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            //if showDots { drawDots() }
            clean()
            drawHorizontalLines()
            //if isCurved {
            //    drawCurvedChart()
            //} else {
            drawChart()
            //}
            //maskGradientLayer()
            drawLables()
        }
    }
    private func drawLables() {
        if let dataEntries = dataEntries,
            dataEntries.count > 0 {
            for i in 0..<dataEntries.count {
                if i % 100 == 0 {
                    let textLayer = CATextLayer()
                    textLayer.frame = CGRect(x: lineGap*CGFloat(i) - lineGap/2 + 80, y: mainLayer.frame.size.height - bottomSpace/2 - 8, width: 200, height: 16)
                    textLayer.foregroundColor = UIColor.white.cgColor// #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                    textLayer.backgroundColor = UIColor.clear.cgColor
                    textLayer.alignmentMode = kCAAlignmentCenter
                    textLayer.contentsScale = UIScreen.main.scale
                    textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                    textLayer.fontSize = 14
                    textLayer.string = dataEntries[i].label
                    mainLayer.addSublayer(textLayer)
                }
            }
        }
    }
    private func drawHorizontalLines() {
        guard let dataEntries = dataEntries else {
            return
        }
        
        var gridValues: [CGFloat]? = nil
        if dataEntries.count < 4 && dataEntries.count > 0 {
            gridValues = [0, 1]
        } else if dataEntries.count >= 4 {
            gridValues = [0, 0.25, 0.5, 0.75, 1]
        }
        if let gridValues = gridValues {
            for value in gridValues {
                let height = value * gridLayer.frame.size.height
                
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: gridLayer.frame.size.width, y: height))
                
                let lineLayer = CAShapeLayer()
                lineLayer.path = path.cgPath
                lineLayer.fillColor = UIColor.clear.cgColor
                lineLayer.strokeColor = UIColor.white.cgColor// #colorLiteral(red: 0.2784313725, green: 0.5411764706, blue: 0.7333333333, alpha: 1).cgColor
                lineLayer.lineWidth = 0.5
                if (value > 0.0 && value < 1.0) {
                    lineLayer.lineDashPattern = [4, 4]
                }
                
                gridLayer.addSublayer(lineLayer)
                
                var minMaxGap:CGFloat = 0
                var lineValue:CGFloat = 0
                if let max = dataEntries.max()?.value,
                    let min = dataEntries.min()?.value {
                    minMaxGap = CGFloat(max - min) * topHorizontalLine
                    lineValue = CGFloat((1-value) * minMaxGap) + CGFloat(min)
                }
                
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: 4, y: height, width: 80, height: 18)
                textLayer.foregroundColor = UIColor.white.cgColor// #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 18
                textLayer.string = "\(lineValue)"
                
                gridLayer.addSublayer(textLayer)
            }
        }
    }
}
