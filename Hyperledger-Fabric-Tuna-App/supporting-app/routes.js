//SPDX-License-Identifier: Apache-2.0

var tuna = require('./controller.js');

module.exports = function(app){
  app.get('/login/:login', function(req,res){
    tuna.login(req,res);
  });
  app.get('/logout', function(req,res){
    tuna.logout(req, res);
  });
  app.get('/registerSupporter/:supporter', function(req, res){
    tuna.registerSupporter(req, res);
  });
  app.get('/registerRecipient/:recipient', function(req, res){
    tuna.registerRecipient(req, res);
  });
  app.get('/get_all_supporter', function(req, res){
    tuna.get_all_supporter(req,res);
  })
  app.get('/get_supporter/:id', function(req, res){
    tuna.get_supporter(req, res);
  });
  app.get('/get_recipient/:id', function(req, res){
    tuna.get_recipient(req, res);
  });
  app.get('/approve_recipient/:appRecipient', function(req, res){
    tuna.approveRecipient(req, res);
  });
  app.get('/add_tuna/:tuna', function(req, res){
    tuna.add_tuna(req, res);
  });
  app.get('/get_all_recipient', function(req, res){
    tuna.get_all_recipient(req, res);
  });
  app.get('/change_supporter_info/:userSupporter', function(req, res){
    tuna.change_supporter_info(req, res);
  });
  app.get('/change_recipient_info/:userRecipient', function(req, res){
    tuna.change_recipient_info(req, res);
  });
}