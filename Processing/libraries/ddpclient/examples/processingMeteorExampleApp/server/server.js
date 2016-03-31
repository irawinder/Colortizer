//
// Methods
//
Meteor.methods({
    addDatum: function (origin,text) {
        DBCollection.insert({
            origin:origin,
            text:text,
            createdAt: new Date()
        });
    },

    clearDatabase: function () {
        DBCollection.remove({}); // {}=everything
    }
});

//
// Server
//
Meteor.startup(function(){
    Meteor.call("addDatum","server","startup");
});

Meteor.publish("data",function(){
    return DBCollection.find();
});