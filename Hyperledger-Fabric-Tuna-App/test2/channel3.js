'use strict';

var express       = require('express');        // call express
var Fabric_Client = require('fabric-client');
var path          = require('path');
var util          = require('util');
var os            = require('os');

var result = null;

async function query1(name, params) {
    console.log("getting all recipients from database: ");

    var fabric_client = new Fabric_Client();

    // setup the fabric network
    var channel = fabric_client.newChannel('mychannel3');
    var peer = fabric_client.newPeer('grpc://localhost:17051'); //peer0Government.org
    
    channel.addPeer(peer);

    var member_user = null;
    var store_path = path.join(os.homedir(), '.hfc-key-store');
    console.log('Store path:'+store_path);
    var tx_id = null;
   
    // create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
    result = Fabric_Client.newDefaultKeyValueStore({ path: store_path
        }).then((state_store) => {
            // assign the store to the fabric client
            fabric_client.setStateStore(state_store);
            var crypto_suite = Fabric_Client.newCryptoSuite();
            // use the same location for the state store (where the users' certificate are kept)
            // and the crypto store (where the users' keys are kept)
            var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
            crypto_suite.setCryptoKeyStore(crypto_store);
            fabric_client.setCryptoSuite(crypto_suite);

            // get the enrolled user from persistence, this user will sign all requests
            return fabric_client.getUserContext('user1', true);
        }).then((user_from_store) => {
            if (user_from_store && user_from_store.isEnrolled()) {
            console.log('Successfully loaded user1 from persistence');
                member_user = user_from_store;
            } else {
                throw new Error('Failed to get user1.... run registerUser.js');
            }

            var request;
            switch (name) {
                case 'queryAllRecipient':
                    request = {
                        chaincodeId: 'test-app-queryRE6',
                        txId: tx_id,
                        fcn: 'queryAllRecipient',
                        args: ['']
                    };
                    break;

                default:
                    break;
            }

            // send the query proposal to the peer
            return channel.queryByChaincode(request);

        }).then((query_responses) => {
            var temp;
            console.log("Query has completed, checking results");
            // query_responses could have more than one  results if there multiple peers were used as targets
            if (query_responses && query_responses.length == 1) {
                if (query_responses[0] instanceof Error) {
                console.error("error from query = ", query_responses[0]);
                } else {
                    console.log("Response is ", query_responses[0].toString());
                    temp = JSON.parse(query_responses[0].toString());
                }
            } else {
                console.log("No payloads were returned from query");
            }
            return temp;
        }).catch((err) => {
            console.error('Failed to query successfully :: ' + err);
        })
        return new Promise(function(resolve, reject) {
            resolve(result);
        });
}

async function query2(name, params) {
    console.log("getting recipient from database: ");

    var fabric_client = new Fabric_Client();
    console.log(params[0]);

    // setup the fabric network
    var channel = fabric_client.newChannel('mychannel3');
    var peer = fabric_client.newPeer('grpc://localhost:37051'); //peer0Government.org
    
    channel.addPeer(peer);

    var member_user = null;
    var store_path = path.join(os.homedir(), '.hfc-key-store');
    console.log('Store path:'+store_path);
    var tx_id = null;
   
    // create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
    result = Fabric_Client.newDefaultKeyValueStore({ path: store_path
        }).then((state_store) => {
            // assign the store to the fabric client
            fabric_client.setStateStore(state_store);
            var crypto_suite = Fabric_Client.newCryptoSuite();
            // use the same location for the state store (where the users' certificate are kept)
            // and the crypto store (where the users' keys are kept)
            var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
            crypto_suite.setCryptoKeyStore(crypto_store);
            fabric_client.setCryptoSuite(crypto_suite);

            // get the enrolled user from persistence, this user will sign all requests
            return fabric_client.getUserContext('user3', true);
        }).then((user_from_store) => {
            if (user_from_store && user_from_store.isEnrolled()) {
            console.log('Successfully loaded user3 from persistence');
                member_user = user_from_store;
            } else {
                throw new Error('Failed to get user3.... run registerUser.js');
            }

            var request;
            switch (name) {
                case 'queryRecipient':
                    request = {
                        chaincodeId: 'test-app-queryRE6',
                        txId: tx_id,
                        fcn: 'queryRecipient',
                        args: [params[0]]
                    };
                    break;

                default:
                    break;
            }

            // send the query proposal to the peer
            return channel.queryByChaincode(request);

        }).then((query_responses) => {
            var temp;
            console.log("Query has completed, checking results");
            // query_responses could have more than one  results if there multiple peers were used as targets
            if (query_responses && query_responses.length == 1) {
                if (query_responses[0] instanceof Error) {
                console.error("error from query = ", query_responses[0]);
                res.send("Could not locate recipient")

            } else {
                    console.log("Response is ", query_responses[0].toString());
                    temp = JSON.parse(query_responses[0].toString());
                }
            } else {
                console.log("No payloads were returned from query");
            }
            return temp;
        }).catch((err) => {
            console.error('Failed to query successfully :: ' + err);
        })
        return new Promise(function(resolve, reject) {
            resolve(result);
        });
}
module.exports.query1 = query1;
module.exports.query2 = query2;