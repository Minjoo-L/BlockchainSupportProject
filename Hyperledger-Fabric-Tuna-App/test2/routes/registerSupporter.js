var express = require('express');
var router = express.Router();  
var session = require('express-session');
var crypto = require('crypto'); //비밀번호 해시화
var channel2Query = require('../channel2.js');

router.post('/supp_reg', async function(req, res){
    var supporter=[];
    supporter[0] = req.body.sname;
    supporter[1] = req.body.sid;
    supporter[2] = req.body.semail;
    supporter[3] = crypto.createHash('sha512').update(req.body.spw).digest('base64');
    supporter[4] = req.body.saddress;
    supporter[5] = req.body.sphoneNum;
    await channel2Query.query3('registerSupporter', supporter);

    res.redirect('/');
});

module.exports = router;