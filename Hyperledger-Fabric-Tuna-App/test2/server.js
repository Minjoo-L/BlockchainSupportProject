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
//var ejs = require('ejs');
var session = require('express-session');//로그인 세션 유지
var FileStore = require('session-file-store')(session);
var crypto = require('crypto'); //비밀번호 해시화
var mysql = require('mysql');

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
// app.use(express.static(__dirname + '/client'));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
//app.engine('html', ejs.renderFile); // html을 뷰 엔진으로
app.set('view engine','ejs');
//app.set('view engine', 'html');
// html 파일 띄우기
app.engine('html', require('ejs').renderFile);

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
    let session = req.session;
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
    res.redirect("/");
});
app.get('/mypage', function(req, res){
    res.render('mypage',{
        session: session
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
            session.auth = rows[0].auth;
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

app.get('/test1', function(req, res){
    res.render('test1',{
        session: session
    });
    console.log("getting all recipients from database: ");

    var fabric_client = new Fabric_Client();

    // setup the fabric network
    var channel = fabric_client.newChannel('mychannel3');
    var peer = fabric_client.newPeer('grpc://localhost:17051'); //peer0Government.org

    channel.addPeer(peer);
    
    //
    var member_user = null;
    var store_path = path.join(os.homedir(), '.hfc-key-store');
    console.log('Store path:'+store_path);
    var tx_id = null;

    // create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
    Fabric_Client.newDefaultKeyValueStore({ path: store_path
    }).then((state_store) => {
        // assign the store to the fabric client
        fabric_client.setStateStore(state_store);
        var crypto_suite = Fabric_Client.newCryptoSuite();
        // use the same location for the state store (where the users' certificate are kept)
        // and the crypto store (where the users' keys are kept)
        var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
        crypto_suite.setCryptoKeyStore(crypto_store);
        fabric_client.setCryptoSuite(crypto_suite);

        // get the enrolled user from persistence, this user will sign all requests
        return fabric_client.getUserContext('user1', true);
    }).then((user_from_store) => {
        if (user_from_store && user_from_store.isEnrolled()) {
            console.log('Successfully loaded user1 from persistence');
            member_user = user_from_store;
        } else {
            throw new Error('Failed to get user1.... run registerUser.js');
        }

        // queryAllTuna - requires no arguments , ex: args: [''],
        const request = {
            chaincodeId: 'test-app-queryRE6',
            txId: tx_id,
            fcn: 'queryAllRecipient',
            args: ['']
        };

        // send the query proposal to the peer
        return channel.queryByChaincode(request);
    }).then((query_responses) => {
        console.log("Query has completed, checking results");
        // query_responses could have more than one  results if there multiple peers were used as targets
        if (query_responses && query_responses.length == 1) {
            if (query_responses[0] instanceof Error) {
                console.error("error from query = ", query_responses[0]);
            } else {
                console.log("Response is ", query_responses[0].toString());
                res.json(JSON.parse(query_responses[0].toString()));
            }
        } else {
            console.log("No payloads were returned from query");
        }
    }).catch((err) => {
        console.error('Failed to query successfully :: ' + err);
    });

});

app.get('/test2', function(req, res) {
    res.render('test2',{
        session: session
    });
});
