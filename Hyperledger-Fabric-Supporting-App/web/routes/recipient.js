var express = require('express');
var router = express.Router();  
var session = require('express-session');
var crypto = require('crypto'); //비밀번호 해시화
var channel3Query = require('../channel3.js');
var channel1Query = require('../channel1.js');

var Sid = "";

router.get('/beforeShowDoVou', async function(req, res){
    sess = req.session;
    if(sess.auth!=1){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        res.render('beforeShowDoVou', {
            session: sess
        })
    }
});
router.post('/showDonateVoucher', async function(req, res){
    sess = req.session;
    if(sess.auth!=1){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var id = req.body.id;
        var pw = req.body.pw;
        pw = crypto.createHash('sha512').update(pw).digest('base64');
        var params = [id];
        var recipient = await channel3Query.query2('queryRecipient', params);
        if(recipient != null && recipient.password == pw && recipient.email == sess.email){
            var DonateVoucher = await channel1Query.query1('queryVoucher', params);
            var voucherUsages = await channel1Query.query1('voucherUsage', params);
            var data2 = [];
            for(voucherUsage of voucherUsages){
                data2.push(voucherUsage);
            }
            res.render('showDonateVoucher', {
                session: sess,
                data: DonateVoucher,
                data2: data2,
                filter: '전체'
            })
        }else{
            res.send('<script type="text/javascript">alert("비밀번호나 주민등록번호를 확인해주세요.");location.href="/mypage";</script>');
        }
    }
});
router.get('/reci_query_result', async function(req, res){
    sess = req.session;
    check = false;
    if(sess.auth!=1&&sess.auth!=2){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var recipients  = await channel3Query.query1('queryAllRecipient');
        var data = [];

        for(recipient of recipients){
            if(recipient.Record.status == 'Y'){
                data.push(recipient);
            }
        }
        res.render('reci_query_result',{
            check: check,
            session: sess,
            data: data
        });
    }
});

 //내 비밀번호 변경(피후원자)
 router.post('/reci_pass_info', async function(req, res){
    sess = req.session;
    if(sess.auth!=1){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var id = req.body.id;
        Sid = id;
        var pw = req.body.password;
        var params =[id];
        var recipient = await channel3Query.query2('queryRecipient', params);
        pw = crypto.createHash('sha512').update(pw).digest('base64');

        if(recipient != null && recipient.password == pw){
            res.render('reci_pass_info',{
                session: sess
            });
        } else{
            // 예외처리 하기
        }
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

router.post('/changePass', async function(req,res){
    sess = req.session;
    if(sess.auth!=1){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var newPassword1 = req.body.newPassword1;
        var newPassword2 = req.body.newPassword2;
        var pw = crypto.createHash('sha512').update(newPassword1).digest('base64');

        if(newPassword1 != newPassword2){
            res.send('<script type="text/javascript">alert("비밀번호가 다릅니다");history.go(-1);</script>');
        }else{
        var params = [Sid, pw];
        await channel3Query.query3('changeRecipientPass', params);
            res.render('changeAl',{
                session: sess
            });
        }
    }
});

router.get('/approveStatus', async function(req,res){
    sess = req.session;
    if(sess.auth!=1){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var params = [sess.email];
        var recipient  = await channel3Query.query2('queryWithOtherInfo', params);
        res.render('approveStatus',{
            data: recipient,
            session: sess
        });
    }
});
router.get('/changeInfo', async function(req,res){
    sess = req.session;
    if(sess.auth!=1){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var params = [sess.email];
        var recipient  = await channel3Query.query2('queryWithOtherInfo', params);
        res.render('changeInfo',{
            data: recipient[0].Record,
            session: sess
        });
    }
});

router.post('/changeReci', async function(req,res){
    sess = req.session;
    if(sess.auth!=1){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
    var address = req.body.address;
    var phoneNum = req.body.phoneNum;
    var story = req.body.story;
    var id = req.body.id;
    var email = req.body.email;
    var job= req.body.job;
    var account=req.body.account;
    var params = [id, account, email, address, phoneNum, job, story];
    await channel3Query.query3('changeAllRecipientInfo', params);
        res.send('<script type="text/javascript">alert("정보가 수정되었습니다.");location.href="/mypage";</script>');
    }
});
module.exports = router;