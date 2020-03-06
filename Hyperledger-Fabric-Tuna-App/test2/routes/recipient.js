var express = require('express');
var router = express.Router();  
var session = require('express-session');
var crypto = require('crypto'); //비밀번호 해시화
var channel3Query = require('../channel3.js');

router.get('/reci_query_result', async function(req, res){
    var recipients  = await channel3Query.query1('queryAllRecipient');
    var data = [];

    for(recipient of recipients){
        data.push(recipient);
    }
    res.render('reci_query_result',{
        session: session,
        data: data
    });
});

router.post('/reci_personal_info', async function(req, res){
    var id = req.body.id;
    var pw = req.body.password;
    var params =[id];
    var recipient  = await channel3Query.query2('queryRecipient', params);
    pw = crypto.createHash('sha512').update(pw).digest('base64');

    if(recipient != null && recipient.pw == pw){
        res.render('reci_personal_info',{
            session: session,
            data: recipient
        });
    } else{
        // 예외처리 하기
    }
});
module.exports = router;