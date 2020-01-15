//
//  CombineLatestCollectionTest.swift
//  CIFilter.ioTests
//
//  Created by Noah Gilmore on 11/14/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import XCTest
@testable import CIFilter_io
import Combine
import SceneKit

class CombineLatestCollectionTest: XCTestCase {
    func testRegularCase() {
        let subject1 = CurrentValueSubject<String, Never>("One")
        let subject2 = CurrentValueSubject<String, Never>("Two")

        var values: [String] = []
        let cancellable = [subject1.eraseToAnyPublisher(), subject2.eraseToAnyPublisher()].combineLatest().map { strings in
            return strings.joined(separator: ",")
        }.sink { value in
            values.append(value)
        }
        XCTAssertEqual(try XCTUnwrap(values.last), "One,Two")
        cancellable.cancel()
    }

    func testNilCurrentValues() {
        let subject1 = CurrentValueSubject<String, Never>("One")
        let subject2 = PassthroughSubject<String, Never>()

        var values: [String] = []
        let cancellable = [subject1.eraseToAnyPublisher(), subject2.eraseToAnyPublisher()].combineLatest().map { strings in
            return strings.joined(separator: ",")
        }.sink { value in
            values.append(value)
        }

        XCTAssertEqual(values, [])

        subject2.send("Two")

        XCTAssertEqual(try XCTUnwrap(values.last), "One,Two")
        cancellable.cancel()
    }

    func testForwardingSubscription() {
        let subject1 = CurrentValueSubject<String, Never>("One")
        let subject2 = CurrentValueSubject<String, Never>("Two")
        let passthrough = PassthroughSubject<[String], Never>()

        var values: [[String]] = []
        let passthroughCancellable = passthrough.sink { value in
            values.append(value)
        }

        let cancellable = [subject1.eraseToAnyPublisher(), subject2.eraseToAnyPublisher()].combineLatest().subscribe(passthrough)
        XCTAssertEqual(try XCTUnwrap(values.last), ["One", "Two"])
        cancellable.cancel()
        passthroughCancellable.cancel()
    }

    func testCompletingSubscription() {
        let just = Just("A")
        let subject = PassthroughSubject<String, Never>()

        var values: [String] = []
        let cancellable = [
            just.eraseToAnyPublisher(),
            subject.eraseToAnyPublisher()
        ].combineLatest().sink { value in
            values.append(value.joined())
        }

        subject.send("B")
        subject.send("C")
        subject.send("D")

        XCTAssertEqual(values, ["AB", "AC", "AD"])

        cancellable.cancel()
    }
}
