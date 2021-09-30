//
//  TransferManager.swift
//  Wallet
//
//  Created by Bernardo Alecrim on 30/09/2021.
//

import BigInt
import Foundation
import web3

struct TransferManager: ABIFunction {

    static var name: String = "transferToken"

    var gasPrice: BigUInt?
    var gasLimit: BigUInt?

    var contract = EthereumAddress("0xcdAd167a8A9EAd2DECEdA7c8cC908108b0Cc06D1")
    var from: EthereumAddress?

    var _wallet: EthereumAddress
    var _token: EthereumAddress
    var _to: EthereumAddress
    var _amount: BigUInt
    var _data: Data

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(_wallet)
        try encoder.encode(_token)
        try encoder.encode(_to)
        try encoder.encode(_amount)
        try encoder.encode(_data)
    }

}

