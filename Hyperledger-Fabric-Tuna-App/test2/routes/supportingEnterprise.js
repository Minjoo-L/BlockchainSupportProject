var express = require('express');
var router = express.Router();  
var session = require('express-session');
var channel3Query = require('../channel3.js');

router.get('/SERecipients', async function(req, res){
    sess = req.session;
    if(sess.auth!=3){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var recipients  = await channel3Query.query1('queryAllRecipient');
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