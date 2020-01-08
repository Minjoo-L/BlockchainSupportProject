//SPDX-License-Identifier: Apache-2.0

var tuna = require('./controller.js');

module.exports = function(app){

  app.get('/registerSupporter/:supporter', function(req, res){
    tuna.registerSupporter(req, res);
  });
  app.get('/get_tuna/:id', function(req, res){
    tuna.get_tuna(req, res);
  });
  app.get('/add_recipient/:tuna', function(req, res){
    tuna.add_recipient(req, res);
  });
  app.get('/get_all_appliedReci', function(req, res){
    tuna.get_all_appliedReci(req, res);
  });
  app.get('/change_holder/:holder', function(req, res){
    tuna.change_holder(req, res);
  });
}
