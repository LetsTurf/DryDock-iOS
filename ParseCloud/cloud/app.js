// These two lines are required to initialize Express in Cloud Code.
var express = require('express');
var app = express();
var versionTracker = require('cloud/versionTracker.js');
 
var VDDModelApp = Parse.Object.extend("VDDModelApp");
 
// Global app configuration section
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'ejs');    // Set the template engine
app.use(express.bodyParser());    // Middleware for reading request body
 
app.post('/builds', function(req, res) {
  console.log(JSON.stringify(req.body));
  return res.send("");
});
 
app.get('/track/:channel', function(req, res) {
  var channel = req.params.channel;
  var bundleIdentifier = req.query['bundle_identifier'];
  versionTracker.versionPackageForTrackerRequest(bundleIdentifier, channel).then(function(versionPackage) {
    return res.send(versionPackage);
  }, function(error) {
    return res.status(500).send(error);
  });
});
 
app.get('/appdownload', function(req, res) {
  return res.render('appdownloadERROR');
});
 
app.get('/appdownload/success', function(req, res) {
  return res.render('appdownloadSUCCESS');
}); 
 
app.get('/appdownload/:objectId', function(req, res) {
  var modelAppQuery = new Parse.Query(VDDModelApp);
  modelAppQuery.get(req.params.objectId).then(function(modelApp) {
    if (!modelApp) {
      return res.render('appdownloadERROR');
    } else {
      var renderPackage = {};
      renderPackage['name'] = modelApp.get('name');
      renderPackage['version_number'] = modelApp.get('version_number');
      renderPackage['install_url'] = modelApp.get('install_url');
      if (modelApp.get('image')) {
        imageUrl = modelApp.get('image').url();
        // imageUrl = imageUrl.replace(/^http:\/\//i, 'https://');
        renderPackage['icon_url'] = imageUrl;
      } else {
        renderPackage['icon_url'] = "http://files.parsetfss.com/8ea13206-bb1e-43a9-9351-a410a901ac61/tfss-cd12e48a-3526-4884-af28-c16986314992-DryDock_Icon120x120.png";
      }
      renderPackage['description'] = modelApp.get('description');
      return res.render('appdownload', renderPackage);
    }
  });
});
 
app.get('/beta/download', function(req, res) {
  var betaObjectId = "khMtipWmj2";
  var betaModelApp = new VDDModelApp();
  betaModelApp.id = betaObjectId;
  return betaModelApp.fetch().then(function() {
    var renderPackage = {};
    renderPackage['name'] = betaModelApp.get('name');
    renderPackage['version_number'] = betaModelApp.get('version_number');
    renderPackage['build_number'] = betaModelApp.get('build_number');
    renderPackage['install_url'] = betaModelApp.get('install_url');
    return res.render('beta', renderPackage);
  });
});
 
app.get('/beta/download/success', function(req, res) {
  return res.render('betaSUCCESS');
});
 
app.listen();