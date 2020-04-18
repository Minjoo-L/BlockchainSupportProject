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

async function getRecipient() {
    
}
module.exports.getRecipient = getRecipient;