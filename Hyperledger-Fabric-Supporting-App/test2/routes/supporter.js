var express = require('express');
var router = express.Router();  
var session = require('express-session');
var crypto = require('crypto'); //비밀번호 해시화
var channel2Query = require('../channel2.js');
var channel1Query = require('../channel1.js');
var channel3Query = require('../channel3.js');


var Sid ="";
var DATA = [];
// 후원자 조회
router.get('/supp_query_result', async function(req, res){
    sess = req.session;
    if(sess.auth!=0&&sess.auth!=2){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var supporters  = await channel2Query.query1('queryAllSupporter');
        var data = [];

        for(supporter of supporters){
            data.push(supporter);
        }
        res.render('supp_query_result',{
            session: sess,
            data: data
        });
    }
});

//내 정보 조회(후원자)
router.get('/supp_personal_info', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
            var params = [sess.email];
            var supporter = await channel2Query.query2('queryWithOtherInfo', params);
            Sid = supporter[0].Record.id;
            res.render('supp_personal_info',{
                session: sess,
                data: supporter[0].Record
            });
        } 
});

//내 비밀번호 변경(후원자)
router.post('/supp_pass_info', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var id = req.body.id;
        Sid = id;
        var pw = req.body.password;
        var params =[id];
        var supporter = await channel2Query.query2('querySupporter', params);
        pw = crypto.createHash('sha512').update(pw).digest('base64');

        if(supporter != null && supporter.pw == pw){
            res.render('supp_pass_info',{
                session: sess
            });
        } else{
            // 예외처리 하기
        }
    }
});

router.post('/changeAl', async function(req,res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var address = req.body.address;
        var phoneNum = req.body.phoneNum;
        var params = [Sid, address, phoneNum];
        await channel2Query.query3('changeSupporterInfo', params);
            res.render('changeAl',{
                session: sess
            });
    }
});

router.post('/changePass', async function(req,res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var newPassword1 = req.body.newPassword1;
        var newPassword2 = req.body.newPassword2;
        var pw = crypto.createHash('sha512').update(newPassword1).digest('base64');

        if(newPassword1 != newPassword2){
            res.send('<script type="text/javascript">alert("비밀번호가 다릅니다");history.go(-1);</script>');
        }else{
        var params = [Sid, pw];
        await channel2Query.query3('changeSupporterPass', params);
            res.render('changeAl',{
                session: sess
            });
        }
    }
});

// 기부기부
router.get('/beforeShowDoVou', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        res.render('beforeShowDoVou', {
            session: sess
        })
    }
});

// 기부한 바우처 내역 조회를 위한 비밀번호 입력 창
router.get('/beforeShowDoVou', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        res.render('beforeShowDoVou', {
            session: sess
        })
    }
});

// 기부한 바우처 내역 조회
router.post('/showDonateVoucher', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var id = req.body.id1+req.body.id2;
        var pw = req.body.pw;
        pw = crypto.createHash('sha512').update(pw).digest('base64');
        var params = [id];
        var supporter = await channel2Query.query2('querySupporter', params);
        if(supporter != null && supporter.pw == pw && supporter.email == sess.email){
            var DonateVoucher = await channel1Query.query1('queryVoucher', params);
            var voucherUsages = await channel1Query.query1('voucherUsage', params);
            var data2 = [];
            for(voucherUsage of voucherUsages){
                data2.push(voucherUsage);
            }
            res.render('showDonateVoucher', {
                session: sess,
                data: DonateVoucher,
                data2: data2,
                filter: '전체'
            })
        }else{
            res.send('<script type="text/javascript">alert("비밀번호나 주민등록번호를 확인해주세요.");location.href="/supporter/beforeShowDoVou";</script>');
        }
        
    }
});

// 바우처 구매
router.get('/purchaseVoucher', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        res.render('purchaseVoucher', {
            session: sess
        })
    }
});

router.post('/purchase', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var id = req.body.id1+req.body.id2;
        var pw = req.body.pw;
        pw = crypto.createHash('sha512').update(pw).digest('base64');
        var amount= req.body.amount;
        var params = [id];
        var supporter = await channel2Query.query2('querySupporter', params);
        if(supporter != null && supporter.pw == pw && supporter.email == sess.email){
            res.render('purchase', {
                session: sess,
                amount: amount,
                id: id
            })
        }else{
            res.send('<script type="text/javascript">alert("비밀번호나 주민등록번호를 확인해주세요.");location.href="/supporter/purchaseVoucher";</script>');
        }
    }
});

router.post('/purchaseResult', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var id = req.body.id;
        var amount= req.body.amount;
        var params = [id, amount];
        await channel1Query.query3('purchaseVoucher', params);
        res.send('<script type="text/javascript">location.href="/supporter/purchaseVoucher";</script>')
    }
})

// 바우처 조회내역 필터링 해서 보여주기
router.post('/filter', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
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
    }
});
// 피후원자 상세보기
router.post('/show_details', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var jsn = JSON.parse(decodeURI(req.body.data));
        res.render('show_details', {
            session:sess,
            data:jsn[0].Record
        })
    }
});
// 후원하기 버튼을 눌러서 후원하는 페이지 이동
router.post('/donatePage', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var name = req.body.name;
        var id = req.body.ReId;

        res.render('donatePage', {
            session:sess,
            name: name,
            id: id
        })
    }
});

// 바우처 기부
router.post('/donate', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var name = req.body.name;
        var ids = req.body.ids1+ids2;
        var idr = req.body.idr;
        var pw = req.body.pw;
        pw = crypto.createHash('sha512').update(pw).digest('base64');
        var number = req.body.number;
        var params2 = [ids];
        var supporter = await channel2Query.query2('querySupporter', params2);
        if(supporter != null && supporter.pw == pw && supporter.email == sess.email){
            var params = [ids, idr, number]; //바우처 번호, 피후원자 식별번호(주민번호)
            //donateV 체인코드
            var voucher = await channel1Query.query2('queryVoucher', params2);
            if(voucher.amount<number){
                res.send('<script type="text/javascript">alert("잔액이 부족합니다.");history.back();</script>'); 
            }else{
                var err = await channel1Query.query3('donateV', params);
                console.log(err);
                res.render('donateComplete', {
                    session: sess,
                    name: name,
                    number: number
                })
            }
        }
        else{
            res.send('<script type="text/javascript">alert("비밀번호나 주민등록번호를 확인해주세요.");location.href="/supporter/donatePage";</script>'); 
        }
    } 
});

// 후원할 피후원자 조회 (후원자)
router.get('/check_Reci', async function(req, res){
    sess = req.session;
    if(sess.auth!=0){
        res.send('<script type="text/javascript">alert("권한이 없습니다.");location.href="/";</script>');
    }else{
        var recipients  = await channel3Query.query1('queryAllRecipient');
        var data = [];
        for(recipient of recipients){
            if(recipient.Record.status == 'Y'){
                data.push(recipient);
            }
        }
        res.render('check_Reci',{
            session: sess,
            data: data
        });
    }
});

module.exports = router;