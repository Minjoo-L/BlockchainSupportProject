var express = require('express');
var router = express.Router();  
var session = require('express-session');
var channel4Query = require('../channel4.js');

router.get('/SERecipient', async function(req, res){
    sess = req.session;

    res.render('SERecipient',{
        session: sess,
        data: data
    });
});

module.exports = router;