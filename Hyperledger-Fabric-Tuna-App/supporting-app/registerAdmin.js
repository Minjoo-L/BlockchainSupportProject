'use strict';
/*
* SPDX-License-Identifier: Apache-2.0
*/
/*
 * Chaincode Invoke
This code is based on code written by the Hyperledger Fabric community.
  Original code can be found here: https://gerrit.hyperledger.org/r/#/c/14395/4/fabcar/enrollAdmin.js
 */

var Fabric_Client = require('fabric-client');
var Fabric_CA_Client = require('fabric-ca-client');

var path = require('path');
var util = require('util');
var os = require('os');

//
var fabric_client = new Fabric_Client();
var fabric_ca_client = null;
var admin_user = null;
var member_user = null;
var crypto_suite = null;
var crypto_store = null;
var tlsOptions = null;
var store_path = path.join(os.homedir(), '.hfc-key-store');
console.log(' Store path:'+store_path);

// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
Fabric_Client.newDefaultKeyValueStore({ path: store_path
}).then((state_store) => {
    // assign the store to the fabric client
    fabric_client.setStateStore(state_store);
    crypto_suite = Fabric_Client.newCryptoSuite();
    // use the same location for the state store (where the users' certificate are kept)
    // and the crypto store (where the users' keys are kept)
    crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
    crypto_suite.setCryptoKeyStore(crypto_store);
    fabric_client.setCryptoSuite(crypto_suite);
    tlsOptions = {
    	trustedRoots: [],
    	verify: false
    };
    //Government Admin 등록
    // be sure to change the http to https when the CA is running TLS enabled
    fabric_ca_client = new Fabric_CA_Client('http://localhost:17054', tlsOptions , 'ca.GovernmentOrg.example.com', crypto_suite);

    // first check to see if the admin is already enrolled
    return fabric_client.getUserContext('admin', true);
}).then((user_from_store) => {
    if (user_from_store && user_from_store.isEnrolled()) {
        console.log('Successfully loaded admin from persistence');
        admin_user = user_from_store;
        return null;
    } else {
        // need to enroll it with CA server
        return fabric_ca_client.enroll({
          enrollmentID: 'admin',
          enrollmentSecret: 'adminpw'
        }).then((enrollment) => {
          console.log('Successfully enrolled admin user "admin"');
          return fabric_client.createUser(
              {username: 'admin',
                  mspid: 'GovernmentOrgMSP',
                  cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
              });
        }).then((user) => {
          admin_user = user;
          return fabric_client.setUserContext(admin_user);
        }).catch((err) => {
          console.error('Failed to enroll and persist admin. Error: ' + err.stack ? err.stack : err);
          throw new Error('Failed to enroll admin');
        });
    }
}).then(() => {
    console.log('Assigned the admin user to the fabric client ::' + admin_user.toString());
}).catch((err) => {
    console.error('Failed to enroll admin: ' + err);
}).then(()=>{ //SupportingEnterprise Admin 등록
  fabric_ca_client = new Fabric_CA_Client('http://localhost:27054', tlsOptions , 'ca.SupportingEnterpriseOrg.example.com', crypto_suite);
    // first check to see if the admin is already enrolled
    return fabric_client.getUserContext('admin2', true);
}).then((user_from_store) => {
    if (user_from_store && user_from_store.isEnrolled()) {
        console.log('Successfully loaded admin2 from persistence');
        admin_user = user_from_store;
        return null;
    } else {
        // need to enroll it with CA server
        return fabric_ca_client.enroll({
          enrollmentID: 'admin2',
          enrollmentSecret: 'adminpw2'
        }).then((enrollment) => {
          console.log('Successfully enrolled admin user "admin2"');
          return fabric_client.createUser(
              {username: 'admin2',
                  mspid: 'SupportingEnterpriseOrgMSP',
                  cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
              });
        }).then((user) => {
          admin_user = user;
          return fabric_client.setUserContext(admin_user);
        }).catch((err) => {
          console.error('Failed to enroll and persist admin2. Error: ' + err.stack ? err.stack : err);
          throw new Error('Failed to enroll admin2');
        });
    }
}).then(() => {
    console.log('Assigned the admin user to the fabric client ::' + admin_user.toString());
}).catch((err) => {
    console.error('Failed to enroll admin2: ' + err);
}).then(()=>{ //Recipeint Admin 등록
  fabric_ca_client = new Fabric_CA_Client('http://localhost:37054', tlsOptions , 'ca.RecipientOrg.example.com', crypto_suite);
    // first check to see if the admin is already enrolled
    return fabric_client.getUserContext('admin3', true);
}).then((user_from_store) => {
    if (user_from_store && user_from_store.isEnrolled()) {
        console.log('Successfully loaded admin3 from persistence');
        admin_user = user_from_store;
        return null;
    } else {
        // need to enroll it with CA server
        return fabric_ca_client.enroll({
          enrollmentID: 'admin3',
          enrollmentSecret: 'adminpw3'
        }).then((enrollment) => {
          console.log('Successfully enrolled admin user "admin3"');
          return fabric_client.createUser(
              {username: 'admin3',
                  mspid: 'RecipientOrgMSP',
                  cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
              });
        }).then((user) => {
          admin_user = user;
          return fabric_client.setUserContext(admin_user);
        }).catch((err) => {
          console.error('Failed to enroll and persist admin3. Error: ' + err.stack ? err.stack : err);
          throw new Error('Failed to enroll admin3');
        });
    }
}).then(() => {
    console.log('Assigned the admin user to the fabric client ::' + admin_user.toString());
}).catch((err) => {
    console.error('Failed to enroll admin3: ' + err);
}).then(()=>{ //Supporter Admin 등록
  fabric_ca_client = new Fabric_CA_Client('http://localhost:47054', tlsOptions , 'ca.SupporterOrg.example.com', crypto_suite);
    // first check to see if the admin is already enrolled
    return fabric_client.getUserContext('admin4', true);
}).then((user_from_store) => {
    if (user_from_store && user_from_store.isEnrolled()) {
        console.log('Successfully loaded admin4 from persistence');
        admin_user = user_from_store;
        return null;
    } else {
        // need to enroll it with CA server
        return fabric_ca_client.enroll({
          enrollmentID: 'admin4',
          enrollmentSecret: 'adminpw4'
        }).then((enrollment) => {
          console.log('Successfully enrolled admin user "admin4"');
          return fabric_client.createUser(
              {username: 'admin4',
                  mspid: 'SupporterOrgMSP',
                  cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
              });
        }).then((user) => {
          admin_user = user;
          return fabric_client.setUserContext(admin_user);
        }).catch((err) => {
          console.error('Failed to enroll and persist admin4. Error: ' + err.stack ? err.stack : err);
          throw new Error('Failed to enroll admin4');
        });
    }
}).then(() => {
    console.log('Assigned the admin user to the fabric client ::' + admin_user.toString());
}).catch((err) => {
    console.error('Failed to enroll admin4: ' + err);
});