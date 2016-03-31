Meteor.subscribe("data");

Meteor.startup(function(){
    Meteor.call("addDatum","browser","startup");
});

//
// Routing
//
Router.route('/',{
    name : 'home',
    template:'home'
});

//
// Template Function
//
Template.home.helpers({

    title:function(){
        return 'Processing-Meteor Sample App';
    },

    data: function(){
        return DBCollection.find({},{sort:{createdAt:-1}});
    }

});

Template.home.events({
    "submit .new-data":function(event){
        event.preventDefault();
        var text = event.target.text.value;
        Meteor.call("addDatum","browser",text);
        event.target.text.value = "";
    },

    "click #delete":function(){
        Meteor.call("clearDatabase");
    }
});