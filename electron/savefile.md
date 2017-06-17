> 使用jquery

      <script src="./node_modules/jquery/dist/jquery.js" onload="window.$ = window.jQuery = module.exports;"></script>
      <script src="./node_modules/jquery/dist/jquery.js"></script>

> [save file](http://ourcodeworld.com/articles/read/106/how-to-choose-read-save-delete-or-create-a-file-with-electron-framework)


    var app = require('electron').remote;
      const {dialog} = require('electron').remote;
      var fs = require('fs');


      document.getElementById('createButton').onclick = () => {
          "use strict";
          dialog.showSaveDialog((fileName) => {
              if (fileName === undefined) {
                  console.log("You didn't save the file");
                  return;
              }

              var content = document.getElementById('content').value;

              fs.writeFile(fileName, content, (err) => {
                  if (err) {
                      alert("An error ocurred creating the file " + err.message)
                  }

                  alert("The file has been succesfully saved");
              });
          });
      };

> open file


    document.getElementById('openButton').onclick =()=>{
        "use strict";
        dialog.showOpenDialog((filename)=>{
            if(filename === undefined) {
                alert('No file selected');
            }else{
                readFile(filename[0]);
            }
        });
    };

    function readFile(filename) {
      fs.readFile(filename,'utf-8',(err,data)=>{
          "use strict";
          if(err){
            alert('An error occured reading the file.');
            return;
          }

          var textArea = document.getElementById('output');
          textArea.value = data;
      })
    }

        // Note that the previous example will handle only 1 file, if you want that the dialog accepts multiple files, then change the settings:
        // And obviously , loop through the fileNames and read every file manually
        dialog.showOpenDialog({ 
            properties: [ 
                'openFile', 'multiSelections', (fileNames) => {
                    console.log(fileNames);
                }
            ]
        });

> update file 

    1 先打开文件 openfile
    2 再更新


    document.getElementById('updateButton').onclick =()=>{
        "use strict";
        dialog.showSaveDialog((filename)=>{
            if(filename === undefined) {
                alert('No file selected');
            }else{
                var content = document.getElementById('output').value;
                fs.writeFile(filename, content, (err) => {
                    if (err) {
                        alert("An error ocurred update the file " + err.message);
                        return;
                    }

                    alert("The file has been succesfully updated");
                });
            }
        });
    };
 