//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
import XCTest

class PaymentMethodListComponentTests: XCTestCase {

    lazy var method1 = StoredPaymentMethodMock(identifier: "identifier", supportedShopperInteractions: [.shopperNotPresent], type: .other("test_stored_type_1"), name: "test_stored_name_1")
    lazy var method2 = PaymentMethodMock(type: .other("test_stored_type_2"), name: "test_stored_name_2")
    lazy var storedComponent = PaymentComponentMock(paymentMethod: method1)
    lazy var regularComponent = PaymentComponentMock(paymentMethod: method2)

    func testRequiresKeyboardInput() {
        let section = ComponentsSection(components: [storedComponent])
        let sectionedComponents = [section]
        let sut = PaymentMethodListComponent(context: Dummy.context, components: sectionedComponents)

        let navigationViewController = DropInNavigationController(rootComponent: sut, style: NavigationStyle(), cancelHandler: { _, _ in })

        XCTAssertFalse((navigationViewController.topViewController as! WrapperViewController).requiresKeyboardInput)
    }
    
    func testLocalizationWithCustomTableName() {
        let storedSection = ComponentsSection(components: [storedComponent])
        let regularSectionHeader = ListSectionHeader(title: "title", style: ListSectionHeaderStyle())
        let regularSection = ComponentsSection(header: regularSectionHeader, components: [regularComponent])
        let sut = PaymentMethodListComponent(context: Dummy.context, components: [storedSection, regularSection])
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        let listViewController = sut.listViewController
        XCTAssertEqual(listViewController.title, localizedString(.paymentMethodsTitle, sut.localizationParameters))
        XCTAssertEqual(listViewController.sections.count, 2)
        XCTAssertEqual(listViewController.sections[1].header?.title, "title")
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let storedSection = ComponentsSection(components: [storedComponent])
        let regularSectionHeader = ListSectionHeader(title: "title", style: ListSectionHeaderStyle())
        let regularSection = ComponentsSection(header: regularSectionHeader, components: [regularComponent])
        let sut = PaymentMethodListComponent(context: Dummy.context, components: [storedSection, regularSection])
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        let listViewController = sut.listViewController
        XCTAssertEqual(listViewController.title, localizedString(LocalizationKey(key: "adyen_paymentMethods_title"), sut.localizationParameters))
        XCTAssertEqual(listViewController.sections.count, 2)
        XCTAssertEqual(listViewController.sections[1].header?.title, "title")
    }

    func testStartStopLoading() {
        let section = ComponentsSection(components: [storedComponent])
        let sut = PaymentMethodListComponent(context: Dummy.context, components: [section])

        UIApplication.shared.keyWindow?.rootViewController = sut.listViewController
        
        wait(for: .milliseconds(300))
        
        let cell = sut.listViewController.tableView.visibleCells[0] as! ListCell
        XCTAssertFalse(cell.showsActivityIndicator)
        sut.startLoading(for: self.storedComponent)
        XCTAssertTrue(cell.showsActivityIndicator)
        sut.stopLoadingIfNeeded()
        XCTAssertFalse(cell.showsActivityIndicator)
    }
    
    func testDeletionSuccess() throws {
        let section = ComponentsSection(header: .init(title: "title",
                                                      editingStyle: .delete,
                                                      style: ListSectionHeaderStyle()),
                                        components: [storedComponent], footer: nil)
        let sut = PaymentMethodListComponent(context: Dummy.context, components: [section, ComponentsSection(components: [regularComponent])])

        UIApplication.shared.keyWindow?.rootViewController = sut.listViewController
        
        wait(for: .milliseconds(300))
        
        let sectionHeader = try XCTUnwrap(sut.listViewController.tableView.headerView(forSection: 0) as? ListHeaderView)
        sectionHeader.trailingButton.sendActions(for: .touchUpInside)
        
        wait(for: .seconds(1))
        
        let allCells = sut.listViewController.tableView.visibleCells
        
        XCTAssertTrue(allCells[0].isEditing)
        XCTAssertFalse(allCells[1].isEditing)
        
        let delegateMock = PaymentMethodListComponentDelegateMock()
        delegateMock.onDidDelete = { paymentMethod, listComponent, completion in
            XCTAssertTrue(listComponent === sut)
            XCTAssertEqual(paymentMethod.identifier, self.method1.identifier)
            completion(true)
        }
        sut.delegate = delegateMock
        
        sut.listViewController.tableView.dataSource?.tableView?(sut.listViewController.tableView,
                                                                commit: .delete,
                                                                forRowAt: IndexPath(item: 0, section: 0))
        
        wait(for: .milliseconds(300))
        
        XCTAssertEqual(sut.listViewController.tableView.visibleCells.count, 1)
        XCTAssertEqual(sut.componentSections.count, 1)
        XCTAssertEqual(sut.componentSections.flatMap(\.components).map(\.paymentMethod.name).reduce("") { result, element in result + element }, regularComponent.paymentMethod.name)

    }
    
    func testDeletionFailure() throws {
        let section = ComponentsSection(header: .init(title: "title",
                                                      editingStyle: .delete,
                                                      style: ListSectionHeaderStyle()),
                                        components: [storedComponent], footer: nil)
        let sut = PaymentMethodListComponent(context: Dummy.context, components: [section, ComponentsSection(components: [regularComponent])])

        UIApplication.shared.keyWindow?.rootViewController = sut.listViewController
        
        wait(for: .milliseconds(300))
        
        let sectionHeader = try XCTUnwrap(sut.listViewController.tableView.headerView(forSection: 0) as? ListHeaderView)
        sectionHeader.trailingButton.sendActions(for: .touchUpInside)
        
        wait(for: .milliseconds(300))
        
        let allCells = sut.listViewController.tableView.visibleCells
        
        XCTAssertTrue(allCells[0].isEditing)
        XCTAssertFalse(allCells[1].isEditing)
        
        let delegateMock = PaymentMethodListComponentDelegateMock()
        delegateMock.onDidDelete = { paymentMethod, listComponent, completion in
            XCTAssertTrue(listComponent === sut)
            XCTAssertEqual(paymentMethod.identifier, self.method1.identifier)
            completion(false)
        }
        sut.delegate = delegateMock
        
        sut.listViewController.tableView.dataSource?.tableView?(sut.listViewController.tableView,
                                                                commit: .delete,
                                                                forRowAt: IndexPath(item: 0, section: 0))
        
        wait(for: .milliseconds(300))
        
        XCTAssertEqual(sut.listViewController.tableView.visibleCells.count, 2)
        XCTAssertEqual(sut.componentSections.count, 2)
        XCTAssertEqual(sut.componentSections.flatMap(\.components).map(\.paymentMethod.name).reduce("") { result, element in result + element }, storedComponent.paymentMethod.name + regularComponent.paymentMethod.name)

    }
    
}
