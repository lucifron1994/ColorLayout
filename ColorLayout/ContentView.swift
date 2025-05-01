//
//  ContentView.swift
//  ColorLayout
//
//  Created by wanghong on 2025/04/30.
//

import SwiftUI
import UIKit

struct SquareFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ContentView: View {
    private enum Constants {
        static let paletteCircleSize: CGFloat = 50
        static let widgetCornerRadius: CGFloat = 36
        static let defaultMargin: CGFloat = 16
    }

    // Main layout tree of colored regions
    @State private var root: RegionNode?
    // Temporary layout used during dragging
    @State private var previewRoot: RegionNode?
    // Currently selected widget color for drag
    @State private var draggingColor: WidgetColor?
    // Current position of the drag gesture
    @State private var dragLocation: CGPoint = .zero
    // Frame of the drop target square area
    @State private var squareFrame: CGRect = .zero
    // Rectangle of the widget inside the square during drag
    @State private var targetRect: CGRect = .zero
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // Use preview layout if dragging, otherwise show final layout
    private var displayRoot: RegionNode? {
        previewRoot ?? root
    }
    
    // Indicates if a preview layout is active during drag
    private var isPreview: Bool {
        previewRoot != nil
    }
    
    // True when a widget is positioned inside the square area
    private var isTransforming: Bool {
        targetRect != .zero
    }
    
    private func resetAll() {
        root = nil
        previewRoot = nil
        draggingColor = nil
        targetRect = .zero
    }
    
    // Build main view, including drop area and palette
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(white: 0.95).edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    ZStack {
                        // Drop area or show welcome message when empty
                        Group {
                            if let node = displayRoot {
                                ForEach(node.leaves(in: squareFrame), id: \.id) { leaf in
                                    if !isPreview || (!isTransforming || leaf.rect != targetRect) {
                                        RoundedRectangle(cornerRadius: Constants.widgetCornerRadius)
                                            .fill(leaf.color.color)
                                            .frame(width: leaf.rect.width, height: leaf.rect.height)
                                            .shadow(
                                                color: isPreview && leaf.rect.contains(dragLocation) ? Color.black.opacity(0.5) : Color.clear,
                                                radius: isPreview && leaf.rect.contains(dragLocation) ? 10 : 0,
                                                x: 0,
                                                y: 2
                                            )
                                            .position(x: leaf.rect.midX, y: leaf.rect.midY - 8)
                                            .animation(.easeInOut(duration: 0.3), value: leaf.rect)
                                    }
                                }
                            } else {
                                VStack(spacing: 32) {
                                    Text("👋").font(.system(size: 50))
                                    Text("Hi!\nDrag and drop your widgets to unleash your creativity!")
                                        .font(.headline)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 28)
                            }
                        }

                        // Draw dashed outline for drop area
                        RoundedRectangle(cornerRadius: Constants.widgetCornerRadius)
                            .stroke(style: StrokeStyle(lineWidth: 4, dash: [8]))
                            .foregroundColor(.gray.opacity(0.4))
                            .frame(width: geo.size.width - Constants.defaultMargin * 2, height: geo.size.width - Constants.defaultMargin * 2)
                            .opacity(root == nil ? 1 : 0)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.preference(
                                        key: SquareFrameKey.self,
                                        value: proxy.frame(in: .named("canvas"))
                                    )
                                }
                            )
                    }
                    Spacer()
                }
                .coordinateSpace(name: "canvas")
                .onPreferenceChange(SquareFrameKey.self) { frame in
                    // Update squareFrame for drop target positioning
                    let expectedMinX = (geo.size.width - (geo.size.width - Constants.defaultMargin * 2)) / 2
                    squareFrame = CGRect(
                        x: expectedMinX,
                        y: frame.minY,
                        width: geo.size.width - Constants.defaultMargin * 2,
                        height: geo.size.width - Constants.defaultMargin * 2
                    )
                }

                // Show preview of currently dragged widget
                if let color = draggingColor {
                    RoundedRectangle(cornerRadius: isTransforming ? Constants.widgetCornerRadius : Constants.paletteCircleSize / 2)
                        .fill(color.color)
                        .frame(
                            width: isTransforming ? targetRect.width : Constants.paletteCircleSize,
                            height: isTransforming ? targetRect.height : Constants.paletteCircleSize
                        )
                        .position(
                            x: isTransforming ? targetRect.midX : dragLocation.x,
                            y: isTransforming ? targetRect.midY : dragLocation.y
                        )
                        .animation(.easeInOut(duration: 0.3), value: isTransforming)
                        .animation(.easeInOut(duration: 0.3), value: dragLocation)
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 2)
                        .zIndex(1)
                }

                // Show bottom color palette for dragging
                paletteView(geo: geo)
            }
            .coordinateSpace(name: "canvas")
            
            if root != nil {
                VStack {
                    HStack {
                        Spacer()
                        Button("Reset") {
                            resetAll()
                        }
                        .padding(Constants.defaultMargin)
                    }
                    Spacer()
                }
            }
        }
    }

    // View showing draggable color palette at bottom
    private func paletteView(geo: GeometryProxy) -> some View {
        VStack {
            Spacer()
            HStack(spacing: 20) {
                ForEach(WidgetColor.allCases, id: \.self) { colorCase in
                    paletteCircle(colorCase)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.white))
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            .padding(.bottom, 20)
        }
    }
    
    // Circle representing a widget color with drag gesture
    private func paletteCircle(_ color: WidgetColor) -> some View {
        ZStack {
            if draggingColor == color {
                Circle()
                    .strokeBorder(color.color, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .frame(width: Constants.paletteCircleSize, height: Constants.paletteCircleSize)
            } else {
                Circle()
                    .fill(color.color)
                    .frame(width: Constants.paletteCircleSize, height: Constants.paletteCircleSize)
            }
        }
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("canvas"))
                .onChanged { value in
                    // First drag event: prepare haptic feedback
                    if draggingColor == nil {
                        feedbackGenerator.prepare()
                        feedbackGenerator.impactOccurred()
                    }
                    draggingColor = color
                    dragLocation = value.location
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if squareFrame.contains(value.location) {
                            // Build a preview layout for the current drag location
                            previewRoot = root?.splitting(at: value.location, in: squareFrame, for: color) ?? .leaf(color: color)
                            // Set the target rectangle for the dragged widget
                            if let leaf = previewRoot?.leaves(in: squareFrame).first(where: { $0.rect.contains(value.location) }) {
                                targetRect = CGRect(
                                    x: max(squareFrame.minX, leaf.rect.minX),
                                    y: leaf.rect.minY,
                                    width: leaf.rect.width,
                                    height: leaf.rect.height
                                )
                            } else {
                                targetRect = .zero
                            }
                        } else {
                            targetRect = .zero
                            previewRoot = nil
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        // On drag end: commit the preview to the main layout
                        if let p = previewRoot {
                            root = p
                        }
                        targetRect = .zero
                        previewRoot = nil
                        draggingColor = nil
                    }
                    feedbackGenerator.impactOccurred()
                }
        )
    }
}

#Preview {
    ContentView()
}
