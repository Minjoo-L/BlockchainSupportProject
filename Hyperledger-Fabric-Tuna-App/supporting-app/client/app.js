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

	$scope.approveRecipient = function(){ //피후원자 등록 승인
		appFactory.approveRecipient($scope.recipient, function(data){
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

	$scope.recordTuna = function(){

		appFactory.recordTuna($scope.tuna, function(data){
			$scope.create_tuna = data;
			$("#success_create").show();
		});
	}

	$scope.changeHolder = function(){

		appFactory.changeHolder($scope.holder, function(data){
			$scope.change_holder = data;
			if ($scope.change_holder == "Error: no tuna catch found"){
				$("#error_holder").show();
				$("#success_holder").hide();
			} else{
				$("#success_holder").show();
				$("#error_holder").hide();
			}
		});
	}
	// 내 정보 수정(후원자)
	$scope.changeSupporterInfo = function(){

		appFactory.changeSupporterInfo($scope.userSupporter, function(data){
			//$scope.change_userSupporter = data;
			/*if ($scope.change_userSupporter == "Error: no tuna catch found"){
				$("#error_holder").show();
				$("#success_holder").hide();
			} else{
				$("#success_holder").show();
				$("#error_holder").hide();
			}*/
		});
	}

});

// Angular Factory
app.factory('appFactory', function($http){
	
	var factory = {};

	//후원자 회원가입
	factory.registerSupporter = function(data, callback){
		var supporter = data.name + "-" + data.id + "-" + data.email + "-" + data.pw + "-" + data.address+"-"+data.phoneNum;
    	$http.get('/registerSupporter/'+supporter).success(function(output){
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

	factory.recordTuna = function(data, callback){

		data.location = data.longitude + ", "+ data.latitude;

		var tuna = data.id + "-" + data.location + "-" + data.timestamp + "-" + data.holder + "-" + data.vessel;

    	$http.get('/add_tuna/'+tuna).success(function(output){
			callback(output)
		});
	}

	factory.changeHolder = function(data, callback){

		var holder = data.id + "-" + data.name;

    	$http.get('/change_holder/'+holder).success(function(output){
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

	return factory;
});