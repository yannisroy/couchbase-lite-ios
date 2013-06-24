var path = require("path");

module.exports = {
  LiteServPath : "/Users/jchris/Library/Developer/Xcode/DerivedData/CouchbaseLite-bhhkqfrlnbnqogachbjesrrwggdn/Build/Products/Debug/LiteServ",
  SyncGatewayPath : "/Users/jchris/code/cb/mobile/sync_gateway/bin/sync_gateway"
}

module.exports.SyncGatewayConfigPath = path.resolve(module.exports.SyncGatewayPath,
  "../../examples/admin_party.json")
