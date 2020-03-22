var express = require('express');
var router = express.Router();  
var session = require('express-session');
var channel3Query = require('../channel3.js');

var data = [];
router.post('/approveAction', async function(req, res){//피후원자 승인
    sess = req.session;
    var rid = req.body.recipientId;
    data = await channel3Query.approveRecipient(rid).then(async function(){
        var data=[];
        var recipients = await channel3Query.query1('queryAllRecipient');

        for(recipient of recipients){
            data.push(recipient);
        }
        return data;
    })
    res.render('approve',{
        session: sess,
        data: data
    });
});
module.exports = router;