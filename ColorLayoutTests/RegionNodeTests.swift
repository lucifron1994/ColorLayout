//
//  RegionNodeTests.swift
//  ColorLayoutTests
//
//  Created by wanghong on 2025/04/30.
//

import XCTest
@testable import ColorLayout

final class RegionNodeTests: XCTestCase {
    
    // Use a 100×100 canvas for tests
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)

    // Split a single leaf vertically
    func testSplittingOnEmptyLeaf() {
        // Start with one skyBlue leaf
        let root = RegionNode.leaf(color: .skyBlue)
        // Point with greater x difference to mid, so split is vertical
        let dropPoint = CGPoint(x: 80, y: 50)
        
        let newRoot = root.splitting(at: dropPoint, in: frame, for: .hotPink)
        
        // Root should be a split node
        guard case let .split(_, axis, left, right) = newRoot else {
            return XCTFail("Expected split node at root")
        }
        // Axis must be vertical
        XCTAssertEqual(axis, .vertical)
        
        // Left child is skyBlue, right child is hotPink
        if case let .leaf(_, leftColor) = left {
            XCTAssertEqual(leftColor, .skyBlue)
        } else {
            XCTFail("Left child should be a leaf with skyBlue")
        }
        if case let .leaf(_, rightColor) = right {
            XCTAssertEqual(rightColor, .hotPink)
        } else {
            XCTFail("Right child should be a leaf with hotPink")
        }
    }
    
    // Do a second split on an existing split node
    func testSplittingNested() {
        // First split: skyBlue splits with hotPink on the right
        let drop1 = CGPoint(x: 80, y: 50)
        let initial = RegionNode.leaf(color: .skyBlue)
            .splitting(at: drop1, in: frame, for: .hotPink)
        
        // Second split: split left half at top-left, add brightYellow
        let drop2 = CGPoint(x: 25, y: 25)
        let updated = initial.splitting(at: drop2, in: frame, for: .brightYellow)
        
        // Root is still vertical split
        guard case let .split(_, rootAxis, leftSubtree, rightSubtree) = updated else {
            return XCTFail("Expected split node at root after nested splitting")
        }
        XCTAssertEqual(rootAxis, .vertical)
        
        // Right side stays hotPink
        if case let .leaf(_, rightColor) = rightSubtree {
            XCTAssertEqual(rightColor, .hotPink)
        } else {
            XCTFail("Right subtree should be hotPink leaf")
        }
        
        // Left side is now a horizontal split
        guard case let .split(_, leftAxis, topLeaf, bottomLeaf) = leftSubtree else {
            return XCTFail("Left subtree should be a split node")
        }
        XCTAssertEqual(leftAxis, .horizontal)
        
        // Top leaf is brightYellow, bottom leaf is skyBlue
        if case let .leaf(_, topColor) = topLeaf {
            XCTAssertEqual(topColor, .brightYellow)
        } else {
            XCTFail("Top leaf should be brightYellow")
        }
        if case let .leaf(_, bottomColor) = bottomLeaf {
            XCTAssertEqual(bottomColor, .skyBlue)
        } else {
            XCTFail("Bottom leaf should be skyBlue")
        }
    }
}
