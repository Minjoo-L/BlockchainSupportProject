var express = require('express');
var router = express.Router();  
var session = require('express-session');
var crypto = require('crypto'); //비밀번호 해시화
var channel3Query = require('../channel3.js');

var Sid = "";

router.get('/reci_query_result', async function(req, res){
    sess = req.session;
    if(sess.auth!=1){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var recipients  = await channel3Query.query1('queryAllRecipient');
        var data = [];

        for(recipient of recipients){
            data.push(recipient);
        }
        res.render('reci_query_result',{
            session: sess,
            data: data
        });
    }
});

router.post('/reci_personal_info', async function(req, res){
    sess = req.session;
    if(sess.auth!=1){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var id = req.body.id;
        Sid = id;
        var pw = req.body.password;
        var params =[id];
        var recipient  = await channel3Query.query2('queryRecipient', params);
        pw = crypto.createHash('sha512').update(pw).digest('base64');

        if(recipient != null && recipient.pw == pw){
            res.render('reci_personal_info',{
                session: sess,
                data: recipient
            });
        } else{
            // 예외처리 하기
        }
    }
});

router.post('/changeRI', async function(req,res){
    sess = req.session;
    var address = req.body.address;
    var phoneNum = req.body.phoneNum;
    var params = [Sid, address, phoneNum];
    await channel2Query.query3('changeRecipientInfo', params);

        res.render('changeAl',{
            session: sess
        });
});

module.exports = router;