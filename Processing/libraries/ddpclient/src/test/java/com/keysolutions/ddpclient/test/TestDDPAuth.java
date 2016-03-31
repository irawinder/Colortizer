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

import junit.framework.TestCase;

import com.keysolutions.ddpclient.DDPClient;
import com.keysolutions.ddpclient.EmailAuth;
import com.keysolutions.ddpclient.TokenAuth;
import com.keysolutions.ddpclient.test.DDPTestClientObserver.DDPSTATE;

/**
 * Tests for authentication
 * @author kenyee
 */
public class TestDDPAuth extends TestCase {

    protected void setUp() throws Exception {
        System.setProperty(org.slf4j.impl.SimpleLogger.DEFAULT_LOG_LEVEL_KEY, "DEBUG");

        super.setUp();
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }
    
    /**
     * Verifies that a bad login is rejected
     * @throws Exception
     */
    public void testBadLogin() throws Exception {
        // create DDP client instance and hook testobserver to it
        DDPClient ddp = new DDPClient(TestConstants.sMeteorHost, TestConstants.sMeteorPort);
        DDPTestClientObserver obs = new DDPTestClientObserver();
        ddp.addObserver(obs);                    
        // make connection to Meteor server
        ddp.connect();          

        // we need to wait a bit before the socket is opened but make sure it's successful
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Connected);
        
        // [password: passwordstring,
        // user: {
        //    username: usernamestring
        // or 
        //    email: emailstring
        // or 
        //    resume: resumetoken (no password required)
        //  }]
        Object[] methodArgs = new Object[1];
        EmailAuth emailpass = new EmailAuth("invalid@invalid.com", "password");
        methodArgs[0] = emailpass;
        int methodId = ddp.call("login", methodArgs, obs);
        assertEquals(1, methodId);  // first ID should be 1
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Connected);
        assertEquals(403, obs.mErrorCode);
        assertEquals("User not found", obs.mErrorReason);
        assertEquals("User not found [403]", obs.mErrorMsg);
        assertEquals("Meteor.Error", obs.mErrorType);
    }
    
    /**
     * Verifies that a bad password is rejected
     * @throws Exception
     */
    public void testBadPassword() throws Exception {
        // create DDP client instance and hook testobserver to it
        DDPClient ddp = new DDPClient(TestConstants.sMeteorHost, TestConstants.sMeteorPort);
        DDPTestClientObserver obs = new DDPTestClientObserver();
        ddp.addObserver(obs);                    
        // make connection to Meteor server
        ddp.connect();          

        // we need to wait a bit before the socket is opened but make sure it's successful
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Connected);
        
        // [password: passwordstring,
        // user: {
        //    username: usernamestring
        // or 
        //    email: emailstring
        // or 
        //    resume: resumetoken (no password required)
        //  }]
        Object[] methodArgs = new Object[1];
        EmailAuth emailpass = new EmailAuth("invalid@invalid.com", "password");
        methodArgs[0] = emailpass;
        int methodId = ddp.call("login", methodArgs, obs);
        assertEquals(1, methodId);  // first ID should be 1
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Connected);
        assertEquals(403, obs.mErrorCode);
        assertEquals("User not found", obs.mErrorReason);
        assertEquals("User not found [403]", obs.mErrorMsg);
        assertEquals("Meteor.Error", obs.mErrorType);
    }

    /**
     * Verifies that email/password login and resume tokens work
     * @throws Exception
     */
    public void testLogin() throws Exception {
        //TODO: does this belong inside the Java DDP client?
        // create DDP client instance and hook testobserver to it
        DDPClient ddp = new DDPClient(TestConstants.sMeteorHost, TestConstants.sMeteorPort);
        DDPTestClientObserver obs = new DDPTestClientObserver();
        ddp.addObserver(obs);                    
        // make connection to Meteor server
        ddp.connect();          

        // we need to wait a bit before the socket is opened but make sure it's successful
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Connected);
        
        // [password: passwordstring,
        // user: {
        //    username: usernamestring
        // or 
        //    email: emailstring
        // or 
        //    resume: resumetoken (no password required)
        //  }]
        Object[] methodArgs = new Object[1];
        EmailAuth emailpass = new EmailAuth(TestConstants.sMeteorUsername, TestConstants.sMeteorPassword);
        methodArgs[0] = emailpass;
        int methodId = ddp.call("login", methodArgs, obs);
        assertEquals(1, methodId);  // first ID should be 1
        
        // we should get a message back after a bit..make sure it's successful
        // we need to grab the "token" from the result for the next test
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.LoggedIn);
        
        // verify that we have the user in the users collection after login
        assertTrue(obs.mCollections.get("users").size() == 1);
        
        //// test out resume token
        String resumeToken = obs.mResumeToken;
        ddp = new DDPClient(TestConstants.sMeteorHost, TestConstants.sMeteorPort);
        obs = new DDPTestClientObserver();
        ddp.addObserver(obs);                    
        // make connection to Meteor server
        ddp.connect();          

        // we need to wait a bit before the socket is opened but make sure it's successful
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Connected);
        
        TokenAuth token = new TokenAuth(resumeToken);
        methodArgs[0] = token;
        methodId = ddp.call("login", methodArgs, obs);
        assertEquals(1, methodId);  // first ID should be 1
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.LoggedIn);
        
        // verify that we have the user in the users collection after login
        assertTrue(obs.mCollections.get("users").size() == 1);
    }
    
    //TODO: test SRP login
    // \"msg\":\"method\",\"method\":\"beginPasswordExchange\",\"params\":[{\"A\":\"df5a724a7e8ecadb707bdeda605b153e9334aaa6390ffe981500583087120b296f92d98ed73abf0f374bf650db26ff3ca392422455cb878ce35868da6e94549d306448e377b41183d33908fb7b36d81e476cce4be7d7b3ea3a5f9a6c3a07fde1a3b0decf8ca4ae28d5bdf29006ef5926aac4cfb97040cbf8375b52c583610b74\",\"user\":{\"email\":\"test@test.com\"}}],\"id\":\"1\"}"]
    // a["{\"msg\":\"result\",\"id\":\"1\",\"result\":{\"identity\":\"SMMN6aCqEdADZHSk8\",\"salt\":\"4vyLDr8dix7YYsWXq\",\"B\":\"300fb1ce2b5e85a3fa7a850f6433a8490f1a0eb3dad8975ffd06063d0b85e8e25c7860cb940dfc5a8483de84c0459c202291f4d888b1ab27e55b051383c3b457d2729666d3f6a75bd5c3caabf770fda5554a49b108c934c1045921a5fc0a3eb95aa33e27d7aa7fe98140b74fa2cb5fc077c6382314c0e1f04408dff2fa56e7a2\"}}"]
    // ["{\"msg\":\"method\",\"method\":\"login\",\"params\":[{\"srp\":{\"M\":\"95ca0290f8ef20a2bccd0ed26c82e777fdedb3b90ec07cda880876e763fff525\"}}],\"id\":\"2\"}"]
    // a["{\"msg\":\"result\",\"id\":\"2\",\"result\":{\"token\":\"BdXLCetbZ3nMaF5nM\",\"id\":\"LQLc7rixstaMZBg8K\",\"HAMK\":\"082c35c1c9f9a2413be960bd5c0d8a76619ae1cb533895d3f5d87759f667d14f\"}}"]
    // http://stackoverflow.com/questions/16729992/authenticating-with-meteor-via-ddp-and-srp/17558300#17558300
}
