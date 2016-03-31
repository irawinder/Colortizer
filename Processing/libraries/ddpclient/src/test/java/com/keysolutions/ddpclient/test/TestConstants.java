/*
* (c)Copyright 2013-2014 Ken Yee, KEY Enterprise Solutions 
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

package com.keysolutions.ddpclient.test;

public final class TestConstants {
    // Specify location of Meteor server (assumes it is running locally)
    // If you're using VirtualBox, you can forward localhost to the VM running Meteor
    public static final String sMeteorHost = "localhost";
    public static final Integer sMeteorPort = 3000;
    //public static final String sMeteorHost = "meteor-test-ddp-endpoint.meteor.com";
    //public static final Integer sMeteorPort = 443;
    
    // note also that your Meteor server app should also have 
    // a user named test@test.com with a password of "password"
    public static final String sMeteorUsername = "test@test.com";
    public static final String sMeteorPassword = "password";
}
