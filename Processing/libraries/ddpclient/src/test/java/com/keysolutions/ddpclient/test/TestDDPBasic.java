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

import java.lang.reflect.Method;

import com.google.gson.Gson;
import com.keysolutions.ddpclient.DDPClient;
import com.keysolutions.ddpclient.EmailAuth;
import com.keysolutions.ddpclient.TokenAuth;
import com.keysolutions.ddpclient.UsernameAuth;

import junit.framework.TestCase;

/**
 * Test misc basic methods in DDP client
 * @author kenyee
 */
public class TestDDPBasic extends TestCase {

    protected void setUp() throws Exception {
        System.setProperty(org.slf4j.impl.SimpleLogger.DEFAULT_LOG_LEVEL_KEY, "DEBUG");

        super.setUp();
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }

    /**
     * Verifies that gson converts auth info classes properly to JSON
     * @throws Exception
     */
    public void testGson2JSonAuthInfo() throws Exception {
        UsernameAuth userpass = new UsernameAuth("test", "pw");
        Gson gson = new Gson();
        String jsonUserpass = gson.toJson(userpass);
        assertEquals("{\"password\":\"pw\",\"user\":{\"username\":\"test\"}}", jsonUserpass);
        // test email/password is encoded properly
        EmailAuth emailpass = new EmailAuth("test@me.com", "pw");
        String jsonEmailpass = gson.toJson(emailpass);
        assertEquals("{\"password\":\"pw\",\"user\":{\"email\":\"test@me.com\"}}", jsonEmailpass);
        // test resumetoken is encoded properly
        TokenAuth token = new TokenAuth("mytoken");
        String jsonToken = gson.toJson(token);
        assertEquals("{\"resume\":\"mytoken\"}", jsonToken);       
    }
    
    /**
     * Verifies that errors are handled properly
     * @throws Exception
     */
    public void testHandleError() throws Exception {
        DDPClient ddp = new DDPClient("", 0);
        DDPTestClientObserver obs = new DDPTestClientObserver();
        ddp.addObserver(obs);
        // do this convoluted thing to test a private method
        Method method = DDPClient.class.getDeclaredMethod("handleError", Exception.class);
        method.setAccessible(true);
        method.invoke(ddp, new Exception("ignore exception"));
        assertEquals("WebSocketClient", obs.mErrorSource);
        assertEquals("ignore exception", obs.mErrorMsg);
    }
}
