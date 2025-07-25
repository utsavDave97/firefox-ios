// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest
@testable import Client

@MainActor
class PocketDataAdaptorTests: XCTestCase {
    private let sleepTime: UInt64 = 1 * NSEC_PER_SEC
    var mockNotificationCenter: MockNotificationCenter!
    var mockPocketAPI: MockPocketAPI!

    override func setUp() {
        super.setUp()
        LegacyFeatureFlagsManager.shared.initializeDeveloperFeatures(with: MockProfile())
        mockNotificationCenter = MockNotificationCenter()
    }

    override func tearDown() {
        super.tearDown()
        mockNotificationCenter = nil
        mockPocketAPI = nil
    }

    func testEmptyData() async throws {
        mockPocketAPI = MockPocketAPI(result: .success([]))
        let subject = createSubject()
        let data = subject.getPocketData()
        try await Task.sleep(nanoseconds: sleepTime)
        XCTAssertEqual(data.count, 0, "Data should be null")
    }

    func testGetPocketData() async throws {
        let stories: [PocketFeedStory] = [
            .make(title: "feed1"),
            .make(title: "feed2"),
            .make(title: "feed3"),
        ]
        mockPocketAPI = MockPocketAPI(result: .success(stories))
        let subject = createSubject()
        try await Task.sleep(nanoseconds: sleepTime)
        let data = subject.getPocketData()
        XCTAssertEqual(data.count, 3, "Data should contain three pocket stories")
    }
}

// MARK: Helper
private extension PocketDataAdaptorTests {
    func createSubject(file: StaticString = #filePath,
                       line: UInt = #line) -> PocketDataAdaptorImplementation {
        let subject = PocketDataAdaptorImplementation(pocketAPI: mockPocketAPI,
                                                      notificationCenter: mockNotificationCenter)
        trackForMemoryLeaks(subject, file: file, line: line)
        return subject
    }
}
