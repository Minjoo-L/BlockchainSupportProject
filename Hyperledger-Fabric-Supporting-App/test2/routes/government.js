var express = require('express');
var router = express.Router();  
var session = require('express-session');
var channel3Query = require('../channel3.js');
var channel1Query = require('../channel1.js');

router.get('/QueryVoucherUsageGov', async function(req, res){
    sess = req.session;
    if(sess.auth!=2){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        res.render('QueryVoucherUsageGov',{
            session: sess
        });
    }
})
router.post('/voucherUsage', async function(req, res){//바우처 내역 조회
    sess = req.session;
    if(sess.auth!=2){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var params = [req.body.id]
        var voucherUsages = await channel1Query.query1('voucherUsage', params);
        var data = [];
        for(voucherUsage of voucherUsages){
            data.push(voucherUsage);
        }
        res.render('voucherUsage',{
            session: sess,
            data: data
        });
    }
})
router.post('/approveAction', async function(req, res){//피후원자 승인
    sess = req.session;
    if(sess.auth!=2){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var data = [];
        var params = [req.body.recipientId, 'Y'];
        //var rid = req.body.recipientId;
       data = await channel3Query.approveRecipient('approveRecipient', params).then(async function(){
            var data=[];
            var recipients = await channel3Query.query1('queryAllRecipient');

            for(recipient of recipients){
                if (recipient.Record.status == 'N')
                data.push(recipient);
            }
            
            res.render('approve',{
                check: true,
                session: sess,
                data: data
            });
        });
       
    }
});
router.post('/CancelApprove', async function(req, res){//피후원자 승인
    sess = req.session;
    if(sess.auth!=2){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var data = [];
        var params = [req.body.recipientId, 'N'];
        console.log(params);
        //var rid = req.body.recipientId;
       data = await channel3Query.approveRecipient('CancelApprove', params).then(async function(){
            var data=[];
            var recipients = await channel3Query.query1('queryAllRecipient');

            for(recipient of recipients){
                if (recipient.Record.status == 'Y')
                data.push(recipient);
            }
            
            res.render('reci_query_result',{
                check: true,
                session: sess,
                data: data
            });
        });
       
    }
});

module.exports = router;