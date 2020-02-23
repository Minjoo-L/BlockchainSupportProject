// SPDX-License-Identifier: Apache-2.0

'use strict';

var app = angular.module('application', []);

// Angular Controller
app.controller('appController', function($scope, appFactory){

	$("#success_holder").hide();
	$("#success_create").hide();
	$("#error_holder").hide();
	$("#error_query").hide();
	$("#success_recipient").hide();
	$("#error_recipient").hide();
	$("#logoutgroup").hide();
	$("#showSend").hide();
	
	$scope.login = function(){ //로그인
		appFactory.login($scope.login, function(data){
			var recieve = data;
			if(recieve == "failed to register"){
				$("#logingroup").show();
				$("#logoutgroup").hide();
			} else{
				$("#logoutgroup").show();
				$("#logingroup").hide();
				var email = recieve.email;
				var name = recieve.name;
				var auth = recieve.auth;
				if(auth==0){
					auth='후원자';
				}
				else if(auth==1){
					auth='피후원자';
				}
				$scope.name = name;
				$scope.auth = auth;
			}
		});
	}
	
	$scope.logout = function(){//로그아웃
		appFactory.logout(function(data){
			if(data == "success"){
				$("#logingroup").show();
				$("#logoutgroup").hide();
			} else{
				$("#logoutgroup").show();
				$("#logingroup").hide();
			}
		});
	}

	$scope.registerSupporter = function(){//후원자 회원가입

		appFactory.registerSupporter($scope.supporter, function(data){
			$scope.create_supporter = data;
		});
	}

	$scope.registerRecipient = function(){//피후원자 회원가입

		appFactory.registerRecipient($scope.recipient, function(data){
			$scope.create_recipient = data;
		});
	}

	//모든 후원자 정보 조회
	$scope.queryAllSupporter = function(){

		appFactory.queryAllSupporter(function(data){
			var array = [];
			for (var i = 0; i < data.length; i++){
				parseInt(data[i].Key);
				data[i].Record.Key = parseInt(data[i].Key);
				array.push(data[i].Record);
			}
			array.sort(function(a, b) {
			    return parseFloat(a.Key) - parseFloat(b.Key);
			});
			$scope.all_supporter = array;
		});
	}

	//모든 피후원자 정보 조회
	$scope.queryAllRecipient = function(){

		appFactory.queryAllRecipient(function(data){
			var array = [];
			for (var i = 0; i < data.length; i++){
				//parseInt(data[i].Key);
				data[i].Record.Key = data[i].Key;
				array.push(data[i].Record);
			}
			array.sort(function(a, b) {
			    return parseFloat(a.Key) - parseFloat(b.Key);
			});
			$scope.all_recipient = array;
		});
	}
	//피후원자 등록 승인
	$scope.approveRecipient = function(){ 
		appFactory.approveRecipient($scope.appRecipient, function(data){
			$scope.approve_recipient = data;
			if ($scope.approve_recipient == "Error: no recipient candidate found"){
				$("#error_recipient").show();
				$("#success_recipient").hide();
			} else{
				$("#success_recipient").show();
				$("#error_recipient").hide();
			}
		});
	}
	// 내 정보 조회 (후원자)
	$scope.querySupporter = function(){

		var id = $scope.supporter_id;

		appFactory.querySupporter(id, function(data){
			$scope.query_supporter = data;

			if ($scope.query_supporter == "Could not locate supporter"){
				console.log()
				$("#error_query").show();
			} else{
				$("#error_query").hide();
			}
		});
	}

	// 바우처 후원하기
	$scope.show = function(){
		console.log('들어옴?');
				$("#showSend").show();

	}
	// 내 정보 조회 (피후원자)
	$scope.queryRecipient = function(){

		var id = $scope.recipient_id;

		appFactory.queryRecipient(id, function(data){
			$scope.query_recipient = data;

			if ($scope.query_recipient == "Could not locate recipient"){
				console.log()
				$("#error_query").show();
			} else{
				$("#error_query").hide();
			}
		});
	}
	// 내 정보 수정(후원자)
	$scope.changeSupporterInfo = function(){

		appFactory.changeSupporterInfo($scope.userSupporter, function(data){
		});
	}

	// 내 정보 수정(피후원자)
	$scope.changeRecipientInfo = function(){

		appFactory.changeRecipientInfo($scope.userRecipient, function(data){
		});
	}

	// 후원자 바우처 구매
	$scope.purchaseVoucher = function(){
		appFactory.purchaseVoucher($scope.voucher, function(data){
		});
	}

	// 후원자 바우처 구매 내역 조회
	$scope.queryPurchaseVoucher= function(){

		var id = $scope.queryPurchaseVoucher_id;

		appFactory.queryPurchaseVoucher(id, function(data){
			var array = [];
			for (var i = 0; i < data.length; i++){
				//parseInt(data[i].Key);
				data[i].Record.Key = data[i].Key;
				array.push(data[i].Record);
			}
			array.sort(function(a, b) {
			    return parseFloat(a.Key) - parseFloat(b.Key);
			});
			$scope.query_voucher = array;
		});
	}

	// 후원자 바우처 구매 내역 조회(정부)
	$scope.allVoucher= function(){

		appFactory.allVoucher(function(data){
			var array = [];
			for (var i = 0; i < data.length; i++){
				//parseInt(data[i].Key);
				data[i].Record.Key = data[i].Key;
				array.push(data[i].Record);
			}
			array.sort(function(a, b) {
			    return parseFloat(a.Key) - parseFloat(b.Key);
			});
			$scope.all_voucher = array;
		});
	}

	// 바우처 후원
	$scope.donateV = function(){

		appFactory.donateV($scope.donateV, function(data){
			$scope.donate_v = data;
		});
	}
});

// Angular Factory
app.factory('appFactory', function($http){
	
	var factory = {};
	factory.login = function(data, callback){//로그인
		var login = data.email + "-" + data.pw;
		$http.get('/login/'+login).success(function(output){
			callback(output)
		});
	}
	factory.logout = function(callback){//로그아웃
		$http.get('/logout').success(function(output){
			callback(output)
		});
	}	
	//후원자 회원가입
	factory.registerSupporter = function(data, callback){
		var supporter = data.name + "-" + data.id + "-" + data.email + "-" + data.pw + "-" + data.address+"-"+data.phoneNum;
    	$http.get('/registerSupporter/'+supporter).success(function(output){
			callback(output)
		});
	}

	//후원자 바우처 구매
	factory.purchaseVoucher = function(data, callback){
		var voucher = data.id + "-" + data.amount + "-" + data.suppEnter;
		$http.get('/purchaseVoucher/'+voucher).success(function(output){
			callback(output)
		});
	}

	//피후원자 회원가입
	factory.registerRecipient = function(data, callback){
		var recipient = data.name + "-" + data.id + "-" + data.email + "-" + data.pw + "-" + data.address+"-"+data.phoneNum+"-"+data.story+"-N";
    	$http.get('/registerRecipient/'+recipient).success(function(output){
			callback(output)
		});
	}

	//모든 후원자 정보 조회
    factory.queryAllSupporter = function(callback){

    	$http.get('/get_all_supporter/').success(function(output){
			callback(output)
		});
	}

	//모든 피후원자 정보 조회
    factory.queryAllRecipient = function(callback){

    	$http.get('/get_all_recipient/').success(function(output){
			callback(output)
		});
	}

	//피후원자 승인 등록
	factory.approveRecipient = function(data, callback){
		var recipient = data.id + "-Y";
    	$http.get('/approve_recipient/'+recipient).success(function(output){
			callback(output)
		});
	}

	// 내 정보 조회 (후원자)
	factory.querySupporter = function(id, callback){
    	$http.get('/get_supporter/'+id).success(function(output){
			callback(output)
		});
	}

	// 내 정보 조회 (피후원자)
	factory.queryRecipient = function(id, callback){
    	$http.get('/get_recipient/'+id).success(function(output){
			callback(output)
		});
	}

	// 내 정보 수정(후원자)
	factory.changeSupporterInfo = function(data, callback){

		var userSupporter = data.id + "-" + data.name + "-" + data.email + "-" + data.pw + "-" + data.address+"-"+data.phoneNum;

    	$http.get('/change_supporter_info/'+userSupporter).success(function(output){
			callback(output)
		});
	}

	// 내 정보 수정(피후원자)
	factory.changeRecipientInfo = function(data, callback){

		var userRecipient = data.id + "-" + data.name + "-" + data.email + "-" + data.password + "-" + data.address+ "-" + data.phoneNum + "-" + data.story + "-" + data.status;

    	$http.get('/change_recipient_info/'+userRecipient).success(function(output){
			callback(output)
		});
	}

	// 후원자 바우처 구매 내역 조회
	factory.queryPurchaseVoucher = function(id, callback){
    	$http.get('/query_purchase_voucher/'+id).success(function(output){
			callback(output)
		});
	}

	// 후원자 바우처 구매 내역 조회(정부)
	factory.allVoucher = function(callback){
    	$http.get('/all_voucher/').success(function(output){
			callback(output)
		});
	}

	// 바우처 후원
	factory.donateV = function(data, callback){
		var donateV = data.id + "-" + data.reci;
    	$http.get('/donateV/'+donateV).success(function(output){
			callback(output)
		});
	}
	return factory;
});
