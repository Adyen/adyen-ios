//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

// TODO: - We mock the response for testing purposes until the backend changes are done.
// Backend Ticket: https://youtrack.is.adyen.com/issue/APIG-105/paymentMethods-upi-app-list-enhancement
// ============================= MOCK =============================

internal struct UPIAppsResponse: Decodable {
    internal let apps: [Issuer]?
}

internal struct UPIAppsResponseMock {

    internal let appsResponse =
        """
        {
          "apps": [
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.google.android.apps.nbu.paisa.user",
                "iosScheme": "tez"
              },
              "id": "gpay",
              "name": "Google Pay"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.phonepe.app",
                "iosScheme": "phonepe"
              },
              "id": "phonepe",
              "name": "PhonePe"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "net.one97.paytm",
                "iosScheme": "paytmmp"
              },
              "id": "paytm",
              "name": "Paytm"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "in.org.npci.upiapp",
                "iosScheme": "bhim"
              },
              "id": "bhim",
              "name": "BHIM"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.dreamplug.androidapp",
                "iosScheme": "credpay"
              },
              "id": "cred",
              "name": "CRED"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.mobikwik_new",
                "iosScheme": "mobikwik"
              },
              "id": "mobikwik",
              "name": "MobiKwik"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.naviapp",
                "iosScheme": "navi"
              },
              "id": "navi",
              "name": "Navi"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "in.amazon.mShop.android.shopping",
                "iosScheme": "amazonpay"
              },
              "id": "amazonpay",
              "name": "Amazon Pay"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.whatsapp",
                "iosScheme": "whatsapp"
              },
              "id": "wapay",
              "name": "WhatsApp Pay"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "indwin.c3.shareapp",
                "iosScheme": "slice-upi"
              },
              "id": "slice",
              "name": "Slice UPI"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.epifi.paisa",
                "iosScheme": "fi"
              },
              "id": "fimoney",
              "name": "Fi Money"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "money.jupiter",
                "iosScheme": "jupiter"
              },
              "id": "jupiter",
              "name": "Jupiter"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "money.super.payments",
                "iosScheme": "supermoney"
              },
              "id": "supermoney",
              "name": "Super.money"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.hdfcbank.payzapp",
                "iosScheme": "payzapp"
              },
              "id": "payzapp",
              "name": "PayZapp"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.freecharge.android",
                "iosScheme": "freecharge"
              },
              "id": "freecharge",
              "name": "Freecharge"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.tatadigital.tcp",
                "iosScheme": "tataneu"
              },
              "id": "tataneu",
              "name": "Tata Neu"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.csam.icici.bank.imobile",
                "iosScheme": "icici"
              },
              "id": "imobile",
              "name": "ICICI Bank iMobile"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.axis.mobile",
                "iosScheme": "axismobile"
              },
              "id": "axisbank",
              "name": "Axis Bank"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.YesBank",
                "iosScheme": "yespay"
              },
              "id": "yesbank",
              "name": "Yes Bank"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.snapwork.hdfc",
                "iosScheme": "hdfcbank"
              },
              "id": "hdfcbank",
              "name": "HDFC Bank"
            },
            {
              "appIdentifierInfo": {
                "androidPackageId": "com.whizdm.moneyview.loans",
                "iosScheme": "moneyview"
              },
              "id": "moneyview",
              "name": "MoneyView"
            }
          ]
        }
        """

    internal var apps: [Issuer]? {
        let data = Data(appsResponse.utf8)
        let decoder = JSONDecoder()
        let response = try? decoder.decode(UPIAppsResponse.self, from: data)
        return response?.apps
    }
}
