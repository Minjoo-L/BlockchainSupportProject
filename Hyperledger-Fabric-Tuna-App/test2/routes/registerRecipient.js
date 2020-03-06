var express = require('express');
var router = express.Router();  
var session = require('express-session');
var crypto = require('crypto'); //비밀번호 해시화
var channel3Query = require('../channel3.js');

router.post('/reci_reg', async function(req, res){
    var recipient=[];
    recipient[0] = req.body.rname;
    recipient[1] = req.body.rid;
    recipient[2] = req.body.remail;
    recipient[3] = crypto.createHash('sha512').update(req.body.rpw).digest('base64');
    recipient[4] = req.body.raddress;
    recipient[5] = req.body.rphoneNum;
    recipient[6] = req.body.rstory;
    recipient[7] = 0;//status 0으로 초기화
    await channel3Query.registerRecipient(recipient);
    res.redirect('/');
});
module.exports = router;