var express = require('express');
var router = express.Router();  
var session = require('express-session');
var channel4Query = require('../channel4.js');

router.get('/SERecipient', async function(req, res){
    sess = req.session;
    if(sess.auth!=3){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var data = [];
        data = channel4Query.getRecipient();
        res.render('SERecipient',{
            session: sess,
            data: data
        });
    }
});

module.exports = router;