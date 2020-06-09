var express = require('express');
var router = express.Router();  
var session = require('express-session');
var channel1Query = require('../channel1.js');
var channel4Query = require('../channel4.js');

router.get('/QueryVoucherUsageGov', async function(req, res){
    sess = req.session;
    if(sess.auth!=3){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        res.render('QueryVoucherUsageGov',{
            session: sess
        });
    }
})
router.post('/voucherUsage', async function(req, res){//바우처 내역 조회
    sess = req.session;
    if(sess.auth!=3){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var params = [req.body.id1+'-'+req.body.id2]
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
router.get('/SERecipients', async function(req, res){
    sess = req.session;
    if(sess.auth!=3){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var recipients  = await channel4Query.query1('queryAllRecipient');
        var data = [];
        for(recipient of recipients){
            data.push(recipient);
        }
        res.render('SERecipients',{
            session: sess,
            data: data
        });
    }
});

module.exports = router;