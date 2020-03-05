var express = require('express');
var router = express.Router();  
var session = require('express-session');
var channel2Query = require('../channel2.js');

// 후원자 조회
router.get('/supp_query_result', async function(req, res){
    var supporters  = await channel2Query.query('queryAllSupporter');
    var data = [];

    for(supporter of supporters){
        data.push(supporter);
    }
    res.render('supp_query_result',{
        session: session,
        data: data
    });
});

//내 정보 조회(후원자)
router.post('/supp_personal_info', async function(req, res){
    var id = req.body.id;
    var password = req.body.password;
    var params =[];
    params[0] = id;
    var supporter = await channel2Query.query2('querySupporter', params);
    console.log(supporter);

    res.render('supp_personal_info',{
        session: session
        
    });
});
module.exports = router;