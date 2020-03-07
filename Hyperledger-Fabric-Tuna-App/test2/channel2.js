'use strict';

var express       = require('express');        // call express
var Fabric_Client = require('fabric-client');
var path          = require('path');
var util          = require('util');
var os            = require('os');
var mysql = require('mysql');

var connection = mysql.createConnection({
	host	: 'localhost',
	user	: 'root',
	password	: '1234',
	database	: 'userdb'
});
connection.connect();

var result = null;

async function query1(name, params) {
    console.log("getting all recipients from database: ");

    var fabric_client = new Fabric_Client();

    // setup the fabric network
    var channel = fabric_client.newChannel('mychannel2');
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
                case 'queryAllSupporter':
                    request = {
                        chaincodeId: 'test-app18',
                        txId: tx_id,
                        fcn: 'queryAllSupporter',
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
    //console.log(params[0]);

    // setup the fabric network
    var channel = fabric_client.newChannel('mychannel2');
    var peer = fabric_client.newPeer('grpc://localhost:47051'); //peer0Government.org
    
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
            return fabric_client.getUserContext('user4', true);
        }).then((user_from_store) => {
            if (user_from_store && user_from_store.isEnrolled()) {
            console.log('Successfully loaded user4 from persistence');
                member_user = user_from_store;
            } else {
                throw new Error('Failed to get user4.... run registerUser.js');
            }

            var request;
            switch (name) {
                case 'querySupporter':
                    request = {
                        chaincodeId: 'test-app18',
		                txId: tx_id,
		                fcn: 'querySupporter',
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

async function query3(func, params) {
	
	var name, id, email, pw, address, phoneNum;
	if (func == "registerSupporter"){
   		console.log("register Supporter: ");
		name = params[0]
		id = params[1]
		email = params[2]
		pw = params[3]
		address = params[4]
		phoneNum = params[5]
		var auth = 0; //후원자는 0번
		
		connection.query("insert into usertbl values('"+name+"' , '"+id+"' , '"+email+"', '"+pw+"' , "+auth+" )", async function(err, rows, fields){
			if(err){
				console.log(err);
			}else{
				console.log("successfully registered!!!");
			}
		});
	}
		var fabric_client = new Fabric_Client();

		// setup the fabric network
		var channel = fabric_client.newChannel('mychannel2');
		var peer = fabric_client.newPeer('grpc://localhost:47051');
		channel.addPeer(peer);
		var order = fabric_client.newOrderer('grpc://localhost:7050')
		channel.addOrderer(order);

		var member_user = null;
		var store_path = path.join(os.homedir(), '.hfc-key-store');
		console.log('Store path:'+store_path);
		var tx_id = null;

		// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
		Fabric_Client.newDefaultKeyValueStore({ path: store_path
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
		    return fabric_client.getUserContext('user4', true);
		}).then((user_from_store) => {
		    if (user_from_store && user_from_store.isEnrolled()) {
		        console.log('Successfully loaded user4 from persistence');
		        member_user = user_from_store;
		    } else {
		        throw new Error('Failed to get user4.... run registerUser.js');
		    }

		    // get a transaction id object based on the current user assigned to fabric client
		    tx_id = fabric_client.newTransactionID();
		    console.log("Assigning transaction_id: ", tx_id._transaction_id);

		    // recordTuna - requires 5 args, ID, vessel, location, timestamp,holder - ex: args: ['10', 'Hound', '-12.021, 28.012', '1504054225', 'Hansel'], 
		    // send proposal to endorser
		   /* const request = {
		        //targets : --- letting this default to the peers assigned to the channel
				chaincodeId: 'test-app18',
				txId: tx_id,
		        fcn: 'registerSupporter',
		        args: [name, id, email, pw, address, phoneNum],
		    };
			*/
			var request;
            switch (func) {
                case 'registerSupporter':
                    request = {
                        chaincodeId: 'test-app18',
						txId: tx_id,
		        		fcn: 'registerSupporter',
		        		args: [name, id, email, pw, address, phoneNum],
                    };
					break;
					
				case 'changeSupporterInfo':
					request = {
						chaincodeId: 'test-app18',
						fcn: 'changeSupporterInfo',
						args: [params[0], params[1], params[2]], // id, address, phoneNum
						chainId: 'mychannel2',
						txId: tx_id
					};
					break;

                default:
                    break;
            }
		    // send the transaction proposal to the peers
		    return channel.sendTransactionProposal(request);
		}).then((results) => {
		    var proposalResponses = results[0];
		    var proposal = results[1];
		    let isProposalGood = false;
		    if (proposalResponses && proposalResponses[0].response &&
		        proposalResponses[0].response.status === 200) {
		            isProposalGood = true;
		            console.log('Transaction proposal was good');
		        } else {
		            console.error('Transaction proposal was bad');
		        }
		    if (isProposalGood) {
		        console.log(util.format(
		            'Successfully sent Proposal and received ProposalResponse: Status - %s, message - "%s"',
		            proposalResponses[0].response.status, proposalResponses[0].response.message));

		        // build up the request for the orderer to have the transaction committed
		        var request = {
		            proposalResponses: proposalResponses,
		            proposal: proposal
		        };

		        // set the transaction listener and set a timeout of 30 sec
		        // if the transaction did not get committed within the timeout period,
		        // report a TIMEOUT status
		        var transaction_id_string = tx_id.getTransactionID(); //Get the transaction ID string to be used by the event processing
		        var promises = [];

		        var sendPromise = channel.sendTransaction(request);
		        promises.push(sendPromise); //we want the send transaction first, so that we know where to check status

		        // get an eventhub once the fabric client has a user assigned. The user
		        // is required bacause the event registration must be signed
		        let event_hub = fabric_client.newEventHub();
		        event_hub.setPeerAddr('grpc://localhost:47053');

		        // using resolve the promise so that result status may be processed
		        // under the then clause rather than having the catch clause process
		        // the status
		        let txPromise = new Promise((resolve, reject) => {
		            let handle = setTimeout(() => {
		                event_hub.disconnect();
		                resolve({event_status : 'TIMEOUT'}); //we could use reject(new Error('Trnasaction did not complete within 30 seconds'));
		            }, 3000);
		            event_hub.connect();
		            event_hub.registerTxEvent(transaction_id_string, (tx, code) => {
		                // this is the callback for transaction event status
		                // first some clean up of event listener
		                clearTimeout(handle);
		                event_hub.unregisterTxEvent(transaction_id_string);
		                event_hub.disconnect();

		                // now let the application know what happened
		                var return_status = {event_status : code, tx_id : transaction_id_string};
		                if (code !== 'VALID') {
		                    console.error('The transaction was invalid, code = ' + code);
		                    resolve(return_status); // we could use reject(new Error('Problem with the tranaction, event status ::'+code));
		                } else {
		                    console.log('The transaction has been committed on peer ' + event_hub._ep._endpoint.addr);
		                    resolve(return_status);
		                }
		            }, (err) => {
		                //this is the callback if something goes wrong with the event registration or processing
		                reject(new Error('There was a problem with the eventhub ::'+err));
		            });
		        });
		        promises.push(txPromise);

		        return Promise.all(promises);
		    } else {
		        console.error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		        throw new Error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		    }
		}).then((results) => {
		    console.log('Send transaction promise and event listener promise have completed');
		    // check the results in the order the promises were added to the promise all list
		    if (results && results[0] && results[0].status === 'SUCCESS') {
		        console.log('Successfully sent transaction to the orderer.');
		        res.send(tx_id.getTransactionID());
		    } else {
		        console.error('Failed to order the transaction. Error code: ' + response.status);
		    }

		    if(results && results[1] && results[1].event_status === 'VALID') {
		        console.log('Successfully committed the change to the ledger by the peer');
		        res.send(tx_id.getTransactionID());
		    } else {
		        console.log('Transaction failed to be committed to the ledger due to ::'+results[1].event_status);
		    }
		}).catch((err) => {
		    console.error('Failed to invoke successfully :: ' + err);
		});
}

module.exports.query1 = query1;
module.exports.query2 = query2;
module.exports.query3 = query3;
