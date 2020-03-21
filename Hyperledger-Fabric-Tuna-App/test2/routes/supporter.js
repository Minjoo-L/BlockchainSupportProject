var express = require('express');
var router = express.Router();  
var session = require('express-session');
var crypto = require('crypto'); //비밀번호 해시화
var channel2Query = require('../channel2.js');
var channel1Query = require('../channel1.js');

var Sid ="";
var DATA = [];
// 후원자 조회
router.get('/supp_query_result', async function(req, res){
    sess = req.session;
    var supporters  = await channel2Query.query1('queryAllSupporter');
    var data = [];

    for(supporter of supporters){
        data.push(supporter);
    }
    res.render('supp_query_result',{
        session: sess,
        data: data
    });
});

//내 정보 조회(후원자)
router.post('/supp_personal_info', async function(req, res){
    sess = req.session;
    var id = req.body.id;
    Sid = id;
    var pw = req.body.password;
    var params =[id];
    var supporter = await channel2Query.query2('querySupporter', params);
    pw = crypto.createHash('sha512').update(pw).digest('base64');

    if(supporter != null && supporter.pw == pw){
        res.render('supp_personal_info',{
            session: sess,
            data: supporter
        });
    } else{
        // 예외처리 하기
    }
});

router.post('/changeAl', async function(req,res){
    sess = req.session;
    var address = req.body.address;
    var phoneNum = req.body.phoneNum;
    var params = [Sid, address, phoneNum];
    await channel2Query.query3('changeSupporterInfo', params);

        res.render('changeAl',{
            session: sess
        });
});

// 기부기부
router.get('/beforeShowDoVou', async function(req, res){
    sess = req.session;
    res.render('beforeShowDoVou', {
        session: sess
    })
});

// 기부한 바우처 내역 조회를 위한 비밀번호 입력 창
router.get('/beforeShowDoVou', async function(req, res){
    sess = req.session;
    res.render('beforeShowDoVou', {
        session: sess
    })
});

// 기부한 바우처 내역 조회
router.post('/showDonateVoucher', async function(req, res){
    sess = req.session;
    var id = req.body.id;
    var params = [id];
    var DonateVoucher = await channel1Query.query1('queryVoucher', params);
    var data = [];

    for(i of DonateVoucher){
            data.push(i);
    }

    DATA = data;

        res.render('showDonateVoucher', {
            session: sess,
            data: data,
            filter: '전체'
        })
});

// 바우처 구매
router.get('/purchaseVoucher', async function(req, res){
    sess = req.session;
    res.render('purchaseVoucher', {
        session: sess
    })
});

router.post('/purchaseResult', async function(req, res){
    sess = req.session;
    var id = req.body.id;
    var amount= req.body.amount;
    var suppEnter = req.body.suppEnter;
    var params = [id, amount, suppEnter];

    await channel1Query.query3('purchaseVoucher', params);
    res.render('purchaseResult',{
        session: sess
    })
});

// 바우처 조회내역 필터링 해서 보여주기
router.post('/filter', async function(req, res){
    sess = req.session;
    var kind = req.body.kind;
    var data = [];
    if (kind == 'all'){
        data = DATA;
        kind = '전체';
    } else if (kind == 'n'){
        for(i of DATA){
            if(i.Record.status == 'N')
                data.push(i);
        }
        kind = '사용 가능';
    } else if (kind == 'y'){
        for(i of DATA){
            if(i.Record.status != 'N')
                data.push(i);
        }
        kind = '사용 완료';
    }
    res.render('showDonateVoucher',{
        session: sess,
        data: data,
        filter: kind
    })
});

// 후원하기 버튼을 눌러서 후원하는 페이지 이동
router.post('/donatePage', async function(req, res){
    sess = req.session;
    var name = req.body.name;
    var id = req.body.ReId;

    res.render('donatePage', {
        session:sess,
        name: name,
        id: id
    })
});

// 바우처 선택후 후원완료
router.post('/donate', async function(req, res){
    sess = req.session;
    console.log("내일 체인코드랑 연결하기");
    var name = req.body.name;
    var id = req.body.id;
    var number = req.body.number;
    var params = [number, id]; //바우처 번호, 피후원자 식별번호(주민번호)
    //donateV 체인코드
   // await channel1Query.query3('purchaseVoucher', params);

    res.render('donateComplete', {
        session: sess,
        name: name,
        number: number
    })
})
module.exports = router;