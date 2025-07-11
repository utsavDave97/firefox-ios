// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import XCTest

class TabCounterTests: FeatureFlaggedTestBase {
    // https://mozilla.testrail.io/index.php?/cases/view/2359077
    func testTabIncrement_tabTrayExperimentOff() {
        addLaunchArgument(jsonFileName: "defaultEnabledOff", featureName: "tab-tray-ui-experiments")
        app.launch()
        navigator.nowAt(NewTabScreen)
        waitForTabsButton()

        var tabsOpen = app.buttons[AccessibilityIdentifiers.Toolbar.tabsButton].value
        XCTAssertEqual("1", tabsOpen as? String)

        navigator.createNewTab()
        navigator.nowAt(NewTabScreen)
        if !iPad() {
            navigator.performAction(Action.CloseURLBarOpen)
        }
        waitForTabsButton()

        tabsOpen = app.buttons[AccessibilityIdentifiers.Toolbar.tabsButton].value
        XCTAssertEqual("2", tabsOpen as? String)

        // Check only for iPhone, for iPad there is not counter in tab tray
        if !iPad() {
            navigator.goto(TabTray)
            let navBarTabTrayButton = app.segmentedControls["navBarTabTray"].buttons.firstMatch
            mozWaitForElementToExist(navBarTabTrayButton)
            XCTAssertTrue(navBarTabTrayButton.isSelected)
            let tabsOpenTabTray: String = navBarTabTrayButton.label
            XCTAssertTrue(tabsOpenTabTray.hasSuffix("2"))
        }
    }

    // https://mozilla.testrail.io/index.php?/cases/view/2359078
    func testTabDecrement_tabTrayExperimentOff() {
        addLaunchArgument(jsonFileName: "defaultEnabledOff", featureName: "tab-tray-ui-experiments")
        app.launch()
        navigator.nowAt(NewTabScreen)
        waitForTabsButton()

        var tabsOpen = app.buttons[AccessibilityIdentifiers.Toolbar.tabsButton].value
        XCTAssertEqual("1", tabsOpen as? String)

        navigator.createNewTab()
        navigator.nowAt(NewTabScreen)

        if !iPad() {
            navigator.performAction(Action.CloseURLBarOpen)
        }
        waitForTabsButton()

        tabsOpen = app.buttons[AccessibilityIdentifiers.Toolbar.tabsButton].value
        XCTAssertEqual("2", tabsOpen as? String)

        navigator.goto(TabTray)

        if isTablet {
            app.otherElements[tabsTray]
                .collectionViews.cells.element(boundBy: 0)
                .buttons[StandardImageIdentifiers.Large.cross].waitAndTap()
        } else {
            let navBarTabTrayButton = app.segmentedControls["navBarTabTray"].buttons.firstMatch
            mozWaitForElementToExist(navBarTabTrayButton)
            XCTAssertTrue(navBarTabTrayButton.isSelected)
            let tabsOpenTabTray: String = navBarTabTrayButton.label
            XCTAssertTrue(tabsOpenTabTray.hasSuffix("2"))

            app.otherElements[tabsTray].cells
                .element(boundBy: 0).buttons[StandardImageIdentifiers.Large.cross].waitAndTap()
        }

        app.otherElements[tabsTray].cells.element(boundBy: 0).waitAndTap()
        navigator.nowAt(NewTabScreen)
        waitForTabsButton()

        tabsOpen = app.buttons[AccessibilityIdentifiers.Toolbar.tabsButton].value
        XCTAssertEqual("1", tabsOpen as? String)

        navigator.goto(TabTray)
        tabsOpen = app.segmentedControls.buttons.element(boundBy: 0).label
        XCTAssertTrue(app.segmentedControls.buttons.element(boundBy: 0).isSelected)
        if !isTablet {
            mozWaitForElementToExist(app.segmentedControls.firstMatch)
            let tabsOpenTabTray: String = app.segmentedControls.buttons.firstMatch.label
            XCTAssertTrue(tabsOpenTabTray.hasSuffix("1"))
        }
    }

    // https://mozilla.testrail.io/index.php?/cases/view/2359078
    func testTabDecrement_tabTrayExperimentOn() {
        addLaunchArgument(jsonFileName: "defaultEnabledOn", featureName: "tab-tray-ui-experiments")
        app.launch()
        navigator.nowAt(NewTabScreen)
        waitForTabsButton()

        var tabsOpen = app.buttons[AccessibilityIdentifiers.Toolbar.tabsButton].value
        XCTAssertEqual("1", tabsOpen as? String)

        navigator.createNewTab()
        navigator.nowAt(NewTabScreen)
        waitForTabsButton()

        tabsOpen = app.buttons[AccessibilityIdentifiers.Toolbar.tabsButton].value
        XCTAssertEqual("2", tabsOpen as? String)

        navigator.goto(TabTray)
        if iPad() {
            app.cells.buttons[StandardImageIdentifiers.Large.cross].firstMatch.waitAndTap()
        } else {
            app.otherElements[tabsTray]
                .collectionViews.cells.element(boundBy: 0)
                .buttons[AccessibilityIdentifiers.TabTray.closeButton].waitAndTap()
        }

        app.otherElements[tabsTray].cells.element(boundBy: 0).waitAndTap()
        navigator.nowAt(NewTabScreen)
        waitForTabsButton()

        tabsOpen = app.buttons[AccessibilityIdentifiers.Toolbar.tabsButton].value
        XCTAssertEqual("1", tabsOpen as? String)

        navigator.goto(TabTray)
        XCTAssertEqual(app.cells.count, 1, "There should be only one tab in the tab tray")
    }
}
