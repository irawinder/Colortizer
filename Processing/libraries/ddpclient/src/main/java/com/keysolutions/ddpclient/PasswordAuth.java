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

package com.keysolutions.ddpclient;

import java.util.HashMap;

/**
 * Base class for Meteor auth formats that need a password
 * @author kenyee
 */
public class PasswordAuth {
    String password;
    HashMap<String,String> user = new HashMap<String,String>();
    
    PasswordAuth(String pw) {
        this.password = pw;
    }
}
