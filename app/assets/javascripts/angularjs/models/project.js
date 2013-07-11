var Project = function(atts){
  var self = this;
  var initialSettings = atts || {};
  //initial settings if passed in
  for(var setting in initialSettings){
    if(initialSettings.hasOwnProperty(setting))
      self[setting] = initialSettings[setting];
  };

  //with some logic...

  //return the scope-safe instance
  return self;
};