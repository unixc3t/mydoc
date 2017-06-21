> index.html
      
      
      <html ng-app="json-app">
      <head>
          <meta charset="UTF-8">
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>Electron Tutorial</title>
          <link rel="stylesheet" href="./node_modules/bootstrap/dist/css/bootstrap.css">
          <script src="./node_modules/angular/angular.js"></script>
          <style>
              #createButton {
                  width:200px;
                  margin: 10px 200px;
              }
          </style>
      </head>
      <body ng-controller="jsonController">
      <div class="container form-container">
          <textarea name="" id="outputText" cols="30" rows="10" class="form-control" placeholder="File Contents..."></textarea>
          <button id="file-butto" ng-click="import()" class="btn btn-success">file button</button>
          <button id="export-button" ng-click="export()" class="btn btn-info">export button</button>
      </div>
      <script>
          require('./js/app.js')
      </script>
      
      

> app.js

    //Startup Angular ,not use angular-router
    var app = angular.module('json-app', []);

    // Initialize requires
    var fs = require('fs');
    var electronApp = require('electron').remote;
    var dialog = electronApp.dialog;


    //Mongojs Initialization
    var mongojs = require('mongojs');
    var db = mongojs('localhost/test', ['user']);

    //Initialize doc elements here
    var textAreaOutput = document.getElementById('outputText');
    var fileButton = document.getElementById('file-button');
    var exportButton = document.getElementById('export-button');
    var exportFileContents;

    // set Controller
    app.controller('jsonController', function ($scope) {

        $scope.import = () => {
            "use strict";
            dialog.showOpenDialog(function (filename) {
                if (filename === undefined) {
                    alert('no File');
                    return;
                }
                fs.readFile(filename[0], (err, data) => {
                    if (err) {
                        alert(err.message);
                        return;
                    }
                    textAreaOutput.value = data;
                    exportFileContents = JSON.parse(data.toString());

                })
            });

        };

        $scope.export = () => {
            "use strict";
            db.user.insert(exportFileContents, (err, records) => {
                if (err) {
                    alert(err.message);
                    return;
                }
                alert('Export');
            });
        };

    });