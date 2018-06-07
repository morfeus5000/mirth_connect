var exec = require('child_process').exec, child;

child = exec('docker ps | grep leviatan',

  function (error, stdout, stderr) {
    // Imprimimos en pantalla con console.log
    
    var s = stdout.split("   ");
	console.log(s[6]);
   	var c = s[6].split(",");

    // controlamos el error
    if (error !== null) {
      console.log('exec error: ' + error);
    }
})
