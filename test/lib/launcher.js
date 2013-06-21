var spawn = require('child_process').spawn;


exports.launchLiteServ = function(opts){
  var run = opts.path,
    argv = ["--port", opts.port];

  if(opts.dir) {
    argv.push("--dir")
    argv.push(opts.dir)
  }

  var liteserv = spawn(opts.path,argv)

  liteserv.stderr.on("data",function(data){
    if (data.toString().indexOf("is listening on port "+opts.port)) {
      liteserv.emit("ready")
    }
  })

  return liteserv;
}
