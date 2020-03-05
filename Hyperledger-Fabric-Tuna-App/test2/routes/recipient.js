var express = require('express');
var router = express.Router();  
var session = require('express-session');
var channel3Query = require('../channel3.js');

router.get('/reci_query_result', async function(req, res){
    var recipients  = await channel3Query.query1('queryAllRecipient');
    var data = [];

    for(recipient of recipients){
        data.push(recipient);
    }
    res.render('reci_query_result',{
        session: session,
        data: data
    });
});

router.post('/reci_personal_info', async function(req, res){
    var id = req.body.id;
    var password = req.body.password;
    var params =[];
    params[0] = id;
    var recipient  = await channel3Query.query2('queryRecipient', params);
    console.log(recipient);

    
    res.render('reci_personal_info',{
        session: session
    });
});
module.exports = router;