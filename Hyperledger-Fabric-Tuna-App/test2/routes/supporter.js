var express = require('express');
var router = express.Router();  
var session = require('express-session');
var crypto = require('crypto'); //비밀번호 해시화
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
    var pw = req.body.password;
    var params =[id];
    var supporter = await channel2Query.query2('querySupporter', params);
    pw = crypto.createHash('sha512').update(pw).digest('base64');

    if(supporter != null && supporter.pw == pw){
        res.render('supp_personal_info',{
            session: session,
            data: supporter
        });
    } else{
        // 예외처리 하기
    }
    
});
module.exports = router;