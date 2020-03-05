var express = require('express');
var router = express.Router();  
var session = require('express-session');
var channel3Query = require('../channel2.js');

router.get('/supp_query_result', async function(req, res){
    var supporters  = await channel3Query.query('queryAllSupporter');
    var data = [];

    for(supporter of supporters){
        data.push(supporter);
    }
    res.render('supp_query_result',{
        session: session,
        data: data
    });
});
module.exports = router;