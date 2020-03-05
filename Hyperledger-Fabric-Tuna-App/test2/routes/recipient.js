var express = require('express');
var router = express.Router();  
var session = require('express-session');
var channel1Query = require('../channel1.js');

//const { Recipient } = require('../models'); 


router.get('/reci_query_result', async function(req, res){
    var recipients  = await channel1Query.query('queryAllRecipient');
    var data = [];

    for(recipient of recipients){
        data.push(recipient);
    }
    res.render('reci_query_result',{
        session: session,
        data: data
    });
});
module.exports = router;