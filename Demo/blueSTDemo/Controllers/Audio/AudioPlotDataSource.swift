//
//  AudioPlotDataSource.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CorePlot

/// Manage a plot view that show an audio signal
public class AudioPlotDataSource: NSObject, CPTPlotDataSource{
    
    private static let plotAudioScaleFactor = 1.0 / 32768.0
    
    /// plot object
    private let graph: CPTXYGraph //graph where plot the feature
    
    /// color to use to draw the line
    public var lineColor = UIColor.red // TODO update line style
    
    /// line width
    public var lineWidth: CGFloat = 2
    
    /// horizontal size of the plot view, used to subsampling the signal to plot
    private let plotWidth: UInt
    
    /// buffer where read the data to plot
    private let audioData: AudioCircularBuffer
    
    private var numberOfSampleAddFromLastDraw: UInt = 0
    private let updateSubsampling: UInt
    
    public var dataToPlot: [AudioCircularBuffer.ScaleSample]
    
    /// initialize the plot view
    ///
    /// - Parameters:
    ///   - view: view where draw the plot
    ///   - dataBuffer: data to plot
    public init(view: CPTGraphHostingView, reDrawAfterSample: UInt, hasDarkTheme: Bool = false) {
        graph = CPTXYGraph(frame: view.bounds)
        updateSubsampling = reDrawAfterSample
        plotWidth = UInt(view.bounds.width)
        audioData = AudioCircularBuffer(size: Int(plotWidth),
                                        scale: AudioCircularBuffer.ScaleSample(Self.plotAudioScaleFactor))
        
        dataToPlot = Array<AudioCircularBuffer.ScaleSample>(repeating: 0, count: Int(plotWidth))
        
        //     NSLog("buffer: \(mAudioData.count) win: \(view.bounds.width)")
        //     NSLog("plotWidth: \(plotWidth)")
        
        super.init();
        view.allowPinchScaling = false
        view.collapsesLayers = true
        
        initializeGraphView(hasDarkTheme: hasDarkTheme)
        
        view.hostedGraph = graph
    }
    
    
    /// initialize the plot with the axis and line styles
    private func initializeGraphView(hasDarkTheme: Bool) {
        if hasDarkTheme {
            graph.apply(CPTTheme(named: CPTThemeName.plainBlackTheme))
        } else {
            graph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))
        }
        
        let dataSourceLinePlot = CPTScatterPlot()
        dataSourceLinePlot.cachePrecision = .double
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth = lineWidth
        lineStyle.lineColor = CPTColor(cgColor:lineColor.cgColor)
        dataSourceLinePlot.dataLineStyle = lineStyle
        dataSourceLinePlot.dataSource = self
        dataSourceLinePlot.showLabels = false
        dataSourceLinePlot.labelTextStyle = nil
        
        graph.add(dataSourceLinePlot)
        
        guard let plotRange = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        
        plotRange.yRange = CPTPlotRange(location: -1.0, length: 2.0)
        plotRange.xRange = CPTPlotRange(location: 0, length: NSNumber(value: plotWidth))
        
        guard let axis = graph.axisSet as? CPTXYAxisSet else { return }
        
        axis.isHidden = true
        axis.xAxis?.labelingPolicy = .none
        axis.yAxis?.labelingPolicy = .none
    }
    
    /// numbner of point to plot
    ///
    /// - Parameter plot: object where plot the point
    /// - Returns: number of point to plot, one for each pixel of the plot
    public func numberOfRecords(for plot: CPTPlot) -> UInt {
        return plotWidth
    }
    
    /// get the point coordinate
    ///
    /// - Parameters:
    ///   - plot: object where draw the plot
    ///   - fieldEnum: x or y coordinate
    ///   - idx: point index
    /// - Returns: x or y coordinate for the point at the specific index
    public func double(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Double {
        guard let scatterField = CPTScatterPlotField(rawValue: Int(fieldEnum)) else { return 0}
        
        switch scatterField {
        case CPTScatterPlotField.Y:
            return Double(dataToPlot[Int(idx)])
        case CPTScatterPlotField.X:
            return Double(idx)
        @unknown default:
            return 0
        }
    }
    
    public func appendToPlot(_ value: Int16) {
        audioData.append(AudioCircularBuffer.Sample(value))
        numberOfSampleAddFromLastDraw = numberOfSampleAddFromLastDraw + 1
        
        if numberOfSampleAddFromLastDraw == updateSubsampling {
            numberOfSampleAddFromLastDraw = 0
            updatePlot()
        }
    }
    
    /// force the plot redraw
    private func updatePlot() {
        DispatchQueue.main.async {
            self.audioData.dumpTo(&self.dataToPlot)
            self.graph.reloadData()
        }
    }
}
