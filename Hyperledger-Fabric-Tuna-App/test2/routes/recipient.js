var express = require('express');
var router = express.Router();  
var session = require('express-session');//로그인 세션 유지

router.get('/reci_query_result', function(req, res){
    res.render('reci_query_result',{
        session: session
    });
});
module.exports = router;