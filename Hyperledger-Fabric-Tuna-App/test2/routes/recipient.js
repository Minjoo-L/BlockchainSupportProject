var express = require('express');
var router = express.Router();  
var session = require('express-session');
var channel1Query = require('../channel1.js');

//const { Recipient } = require('../models'); 


router.get('/reci_query_result', async function(req, res){
    var recipients  = await channel1Query.query('queryAllRecipient');
    var data = [];
    console.log(recipients);
    console.log('좀 데이터 좀 보여줘.. 데이터 조회 되기 전에 니가 먼저 실행되는거니', `${recipients}`);
    res.render('reci_query_result',{
        session: session
    });
});
module.exports = router;