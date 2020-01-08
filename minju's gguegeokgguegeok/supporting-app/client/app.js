// SPDX-License-Identifier: Apache-2.0

'use strict';

var app = angular.module('application', []);

// Angular Controller
app.controller('appController', function($scope, appFactory){

	//$("#success_holder").hide();
	$("#success_create").hide();
	//$("#error_holder").hide();
	//$("#error_query").hide();
	
	$scope.registerSupporter = function(){//후원자 회원가입

		appFactory.registerSupporter($scope.supporter, function(data){
		});
	}

	$scope.getApplyReciInfo = function(){

		appFactory.getApplyReciInfo(function(data){
			var array = [];
			for (var i = 0; i < data.length; i++){
				parseInt(data[i].Key);
				data[i].Record.Key = parseInt(data[i].Key);
				array.push(data[i].Record);
			}
			array.sort(function(a, b) {
			    return parseFloat(a.Key) - parseFloat(b.Key);
			});
			$scope.all_recipient = array;
		});
	}

	/*$scope.queryTuna = function(){

		var id = $scope.tuna_id;

		appFactory.queryTuna(id, function(data){
			$scope.query_tuna = data;

			if ($scope.query_tuna == "Could not locate tuna"){
				console.log()
				$("#error_query").show();
			} else{
				$("#error_query").hide();
			}
		});
	}
*/
	/*$scope.recordTuna = function(){

		appFactory.recordTuna($scope.tuna, function(data){
			$scope.create_tuna = data;
			$("#success_create").show();
		});
	}
*/
	$scope.applyForRecipient = function(){

		appFactory.applyForRecipient($scope.recipient, function(data){
			$scope.create_recipient = data;
			$("#success_create").show();
		});
	}

	/*$scope.changeHolder = function(){

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
*/
});

// Angular Factory
app.factory('appFactory', function($http){
	
	var factory = {};

	//후원자 회원가입
	factory.registerSupporter = function(data, callback){
		var supporter = data.name + "-" + data.id + "-" + data.email + "-" + data.pw + "-" + data.address+"-"+data.phoneNum+"-"+0;
    	$http.get('/registerSupporter/'+supporter).success(function(output){
			callback(output)
		});
	}

    /*factory.queryAllTuna = function(callback){

    	$http.get('/get_all_tuna/').success(function(output){
			callback(output)
		});
	}*/

	factory.getApplyReciInfo = function(callback){

    	$http.get('/get_all_appliedReci/').success(function(output){
			callback(output)
		});
	}

	/*factory.queryTuna = function(id, callback){
    	$http.get('/get_tuna/'+id).success(function(output){
			callback(output)
		});
	}*/

	/*factory.recordTuna = function(data, callback){

		data.location = data.longitude + ", "+ data.latitude;

		var tuna = data.id + "-" + data.location + "-" + data.timestamp + "-" + data.holder + "-" + data.vessel;

    	$http.get('/add_tuna/'+tuna).success(function(output){
			callback(output)
		});
	}
*/
	factory.applyForRecipient = function(data, callback){

		var recipient = data.num + "-" + data.name+ "-" + data.id + "-" + data.email + "-" + data.password + "-" + data.address + "-" + data.phoneNum + "-" + data.story + "-" + data.status;

    	$http.get('/add_recipient/'+recipient).success(function(output){
			callback(output)
		});
	}

	/*factory.changeHolder = function(data, callback){

		var holder = data.id + "-" + data.name;

    	$http.get('/change_holder/'+holder).success(function(output){
			callback(output)
		});
	}*/

	return factory;
});


