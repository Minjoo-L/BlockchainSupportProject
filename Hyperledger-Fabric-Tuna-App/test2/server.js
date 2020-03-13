//SPDX-License-Identifier: Apache-2.0

// nodejs server setup 

// call the packages we need
var express       = require('express');        // call express
var bodyParser    = require('body-parser');
var http          = require('http')
var fs            = require('fs');
var Fabric_Client = require('fabric-client');
var path          = require('path');
var util          = require('util');
var os            = require('os');
var session = require('express-session');//로그인 세션 유지
var FileStore = require('session-file-store')(session);
var crypto = require('crypto'); //비밀번호 해시화
var mysql = require('mysql');
var channel3Query = require('./channel3.js');
// 라우터
var recipientRouter = require('./routes/recipient');
var headerRouter = require('./routes/header');
var supporterRouter = require('./routes/supporter');
var registerSRouter = require('./routes/registerSupporter');
var registerRRouter = require('./routes/registerRecipient');

var connection = mysql.createConnection({
    host    : 'localhost',
    user    : 'root',
    password    : '1234',
    database    : 'userdb'
});
connection.connect();

// instantiate the app
var app = express();

// Load all of our middleware
// configure app to use bodyParser()
// this will let us get the data from a POST
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.set('view engine','ejs');

// set up a static file server that points to the "client" directory
app.use(express.static(path.join(__dirname, './client')));
app.use(session({
    secret: 'thisissecret', //세션 암호화
    resave: false,
    saveUninitialized: true
}));


// Save our port
var port = process.env.PORT || 8000;

// Start the server and listen on port 
app.listen(port,function(){
  console.log("Live on port: " + port);
});

app.get('/', function(req, res){
    //let session = req.session;
    res.render('index',{
        session: session
    });
});
app.get('/index', function(req, res){
    res.render('index',{
        session: session
    });
});
app.get('/login', function(req, res){
    res.render('login',{
        session: session
    });
});
app.get('/logout', function(req, res){
    delete req.session;
    res.render('index',{
        session: session
    });
});
app.get('/register', function(req, res){
    res.render('register',{
        session: session
    });
});
app.get('/registerSupporter', function(req, res){
    res.render('registerSupporter',{
        session: session
    });
});
app.get('/registerRecipient', function(req, res){
    res.render('registerRecipient',{
        session: session
    });
});
app.get('/mypage', function(req, res){
    res.render('mypage',{
        session: session
    });
});
app.get('/approve', async function(req, res){
    var recipients  = await channel3Query.query1('queryAllRecipient');
    var data = [];
    console.log(recipients);
    for(recipient of recipients){
        data.push(recipient);
    }
    res.render('approve',{
        session: session,
        data: data
    });
});
app.post('/mypage', function(req,res){
    console.log("login : ");
    var email = req.body.email;
    var pw = req.body.pw;
    pw = crypto.createHash('sha512').update(pw).digest('base64');

    connection.query("select * from usertbl where Email = '"+email+"' and Password = '"+pw+"'", async function(err, rows, fields){
        if(err){
            console.log(err);
        }
        else if(rows.length==1){//로그인 성공
            session.Name = rows[0].Name;
            session.email = rows[0].Email;
            session.auth = rows[0].auth;   // auth로 다시 바꿔주기
            console.log('success');
            console.log(session.Name);
            res.render("mypage",{
                session: session
            });
        }
        else{
            res.send('failed to login');
            res.redirect("/login");
        }
    });
});

app.use('/recipient', recipientRouter);
app.use('/header', headerRouter);
app.use('/supporter', supporterRouter);
app.use('/registerSupporter', registerSRouter);
app.use('/registerRecipient', registerRRouter);
module.exports = app;