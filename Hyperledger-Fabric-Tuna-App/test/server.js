//SPDX-License-Identifier: Apache-2.0

// nodejs server setup 

// call the packages we need
var express       = require('express');        // call express
var app           = express();                 // define our app using express
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

var connection = mysql.createConnection({
	host	: 'localhost',
	user	: 'root',
	password	: '1234',
	database	: 'userdb'
});
connection.connect();

// Load all of our middleware
// configure app to use bodyParser()
// this will let us get the data from a POST
// app.use(express.static(__dirname + '/client'));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.set('view engine','ejs');

// instantiate the app
var app = express();

// this line requires and runs the code from our routes.js file and passes it app
require('./routes.js')(app);

// set up a static file server that points to the "client" directory
app.use(express.static(path.join(__dirname, './client')));

app.use(session({
	secret: 'thisissecret', //세션 암호화
	resave: false,
	saveUninitialized: true,
	store: new FileStore()
}));

// Save our port
var port = process.env.PORT || 8000;

// Start the server and listen on port 
app.listen(port,function(){
  console.log("Live on port: " + port);
});

app.get('/', (req,res)=>{
  const sess = req.session;
});

app.get('/login/:login', (req,res)=>{ //로그인
  console.log("login : ");
		var array = req.params.login.split("-");
		var email = array[0];
		var pw = array[1];
		pw = crypto.createHash('sha512').update(pw).digest('base64');
		connection.query("select * from usertbl where Email = '"+email+"' and Password = '"+pw+"'", async function(err, rows, fields){
			if(err){
				console.log(err);
			}
			else if(rows.length==1){//로그인 성공
				req.session.email = rows[0].Email;
				req.session.name = rows[0].Name;
				req.session.auth = rows[0].auth;
				res.send(req.session);
				console.log('success');
				console.log(req.session.email);
			}
			else{
				res.send('failed to login');
			}
		});
});

app.get('/logout', (req,res)=>{ //로그아웃
    console.log(req.session.email);
		delete req.session;
		res.send('success');
});