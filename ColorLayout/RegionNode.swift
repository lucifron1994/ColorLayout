//
//  RegionNode.swift
//  ColorLayout
//
//  Created by wanghong on 2025/04/30.
//

import Foundation

enum Axis: Equatable {
    case horizontal, vertical
}

// RegionNode is a recursive tree that stores colored areas or splits
indirect enum RegionNode: Identifiable, Equatable {
    case leaf(id: UUID = UUID(), color: WidgetColor)
    case split(id: UUID = UUID(), axis: Axis, first: RegionNode, second: RegionNode)

    var id: UUID {
        switch self {
        case .leaf(let id, _), .split(let id, _, _, _):
            return id
        }
    }
}

extension RegionNode {
    // Split the region at a point and add a new colored leaf
    func splitting(at point: CGPoint, in frame: CGRect, for color: WidgetColor) -> RegionNode {
        switch self {
        case .leaf(let id, let existingColor):
            let mid = CGPoint(x: frame.midX, y: frame.midY)
            // Distance from point to center on x and y
            let dx = abs(point.x - mid.x)
            let dy = abs(point.y - mid.y)
            // Choose split axis by larger distance
            let axis: Axis = dx > dy ? .vertical : .horizontal
            // Keep the old color in one leaf
            let first = RegionNode.leaf(id: id, color: existingColor)
            // Create a new leaf with the new color
            let second = RegionNode.leaf(id: UUID(), color: color)
            // Determine if new leaf goes in the second half
            let isSecond = (axis == .horizontal ? point.y > mid.y : point.x > mid.x)
            return .split(axis: axis,
                          first: isSecond ? first : second,
                          second: isSecond ? second : first)

        // If node is already split, pass split request down
        case .split(_, let axis, let a, let b):
            // Compute sub-frames based on split axis
            let (f1, f2): (CGRect, CGRect)
            switch axis {
            case .horizontal:
                let h = frame.height / 2
                f1 = CGRect(x: frame.minX, y: frame.minY,
                            width: frame.width, height: h)
                f2 = CGRect(x: frame.minX, y: frame.minY + h,
                            width: frame.width, height: h)
            case .vertical:
                let w = frame.width / 2
                f1 = CGRect(x: frame.minX, y: frame.minY,
                            width: w, height: frame.height)
                f2 = CGRect(x: frame.minX + w, y: frame.minY,
                            width: w, height: frame.height)
            }
            // Recurse into the correct child based on point location
            if (axis == .horizontal && point.y < f2.minY) ||
               (axis == .vertical && point.x < f2.minX) {
                return .split(axis: axis,
                              first: a.splitting(at: point, in: f1, for: color),
                              second: b)
            } else {
                return .split(axis: axis,
                              first: a,
                              second: b.splitting(at: point, in: f2, for: color))
            }
        }
    }

    // Collect all leaf nodes with their color and frame
    func leaves(in frame: CGRect) -> [(id: UUID, color: WidgetColor, rect: CGRect)] {
        switch self {
        // Base case: single leaf region
        case .leaf(let id, let color):
            return [(id: id, color: color, rect: frame)]
        // Split node: get leaves from both sub-regions
        case .split(_, let axis, let c1, let c2):
            let (f1, f2): (CGRect, CGRect)
            switch axis {
            case .horizontal:
                let h = frame.height / 2
                f1 = CGRect(x: frame.minX, y: frame.minY,
                            width: frame.width, height: h)
                f2 = CGRect(x: frame.minX, y: frame.minY + h,
                            width: frame.width, height: h)
            case .vertical:
                let w = frame.width / 2
                f1 = CGRect(x: frame.minX, y: frame.minY,
                            width: w, height: frame.height)
                f2 = CGRect(x: frame.minX + w, y: frame.minY,
                            width: w, height: frame.height)
            }
            // Combine leaves from first and second subframes
            return c1.leaves(in: f1) + c2.leaves(in: f2)
        }
    }
}
