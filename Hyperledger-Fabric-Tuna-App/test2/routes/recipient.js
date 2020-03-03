var express = require('express');
var router = express.Router();  
var session = require('express-session');

router.get('/reci_query_result', function(req, res){
    res.render('reci_query_result',{
        session: session
    });
});
module.exports = router;