var express = require('express');
var router = express.Router();  
var session = require('express-session');//로그인 세션 유지

router.get('/query', function(req, res){
    sess = req.session;
    res.render('query',{
        session: sess
    });
});

module.exports = router;