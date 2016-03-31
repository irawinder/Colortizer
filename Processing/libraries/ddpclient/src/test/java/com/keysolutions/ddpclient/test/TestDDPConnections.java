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
import java.net.URISyntaxException;

import junit.framework.TestCase;

import com.keysolutions.ddpclient.DDPClient;
import com.keysolutions.ddpclient.test.DDPTestClientObserver.DDPSTATE;

public class TestDDPConnections extends TestCase {

    protected void setUp() throws Exception {
        System.setProperty(org.slf4j.impl.SimpleLogger.DEFAULT_LOG_LEVEL_KEY, "DEBUG");

        super.setUp();
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }
        
    /**
     * Verifies connection closed callback handler works (doesn't require a connection)
     * @throws Exception
     */
    public void testConnectionClosed() throws Exception {
        DDPClient ddp = new DDPClient("", 0);
        DDPTestClientObserver obs = new DDPTestClientObserver();
        ddp.addObserver(obs);
        // do this convoluted thing to test a private method
        Method method = DDPClient.class.getDeclaredMethod("connectionClosed", int.class, String.class, boolean.class);
        method.setAccessible(true);
        method.invoke(ddp, 5, "test", true);
        assertEquals(5, obs.mCloseCode);
        assertEquals("test", obs.mCloseReason);
        assertEquals(true, obs.mCloseFromRemote);
    }
    
    /**
     * Checks that disconnect closes connection properly
     * @throws URISyntaxException 
     * @throws InterruptedException 
     */
    public void testDisconnect() throws URISyntaxException, InterruptedException {
        // create DDP client instance and hook testobserver to it
        DDPClient ddp = new DDPClient(TestConstants.sMeteorHost, TestConstants.sMeteorPort);
        DDPTestClientObserver obs = new DDPTestClientObserver();
        ddp.addObserver(obs);                    
        // make connection to Meteor server
        ddp.connect();          

        // we need to wait a bit before the socket is opened but make sure it's successful
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Connected);

        // try disconnect
        ddp.disconnect();
        
        // wait a bit to make sure our state has changed to closed
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Closed);
    }
    
    /**
     * Tests that we can handle reconnections to the server
     * @throws URISyntaxException
     * @throws InterruptedException
     */
    public void testReconnect() throws URISyntaxException, InterruptedException {
        // create DDP client instance and hook testobserver to it
        DDPClient ddp = new DDPClient(TestConstants.sMeteorHost, TestConstants.sMeteorPort);
        DDPTestClientObserver obs = new DDPTestClientObserver();
        ddp.addObserver(obs);                    
        // make connection to Meteor server
        ddp.connect();          

        // we need to wait a bit before the socket is opened but make sure it's successful
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Connected);

        // try disconnect
        ddp.disconnect();
        
        // wait a bit to make sure our state has changed to closed
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Closed);
        
        // now test that we can reconnect to the server
        ddp.connect();

        // we need to wait a bit before the socket is opened but make sure it's successful
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Connected);

        // try disconnect
        ddp.disconnect();
        
        // wait a bit to make sure our state has changed to closed
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Closed);
    }
    
    
    /**
     * Tests that the server ping command is handled properly
     * @throws URISyntaxException
     * @throws InterruptedException
     */
    public void testPing() throws URISyntaxException, InterruptedException {
        // create DDP client instance and hook testobserver to it
        DDPClient ddp = new DDPClient(TestConstants.sMeteorHost, TestConstants.sMeteorPort);
        DDPTestClientObserver obs = new DDPTestClientObserver();
        ddp.addObserver(obs);                    
        // make connection to Meteor server
        ddp.connect();          

        // we need to wait a bit before the socket is opened but make sure it's successful
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Connected);

        // send a ping and verify we got a pong back
        assertTrue(obs.mPingId == null);
        ddp.ping("ping1", obs);
        Thread.sleep(500);
        assertNotNull(obs.mPingId);
        assertTrue(obs.mPingId.equals("ping1"));
        
        // try disconnect
        ddp.disconnect();
        
        // wait a bit to make sure our state has changed to closed
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Closed);
    }
    
    
    
    /**
     * Checks that we can connect to the server using SSL
     * @throws URISyntaxException 
     * @throws InterruptedException 
     */
    public void testUseSSL() throws URISyntaxException, InterruptedException {
        //NOTE: this test will only pass if we're connecting to the server using SSL:
        if (TestConstants.sMeteorPort != 443) {
            return;
        }
        
        // create DDP client instance and hook testobserver to it
        DDPClient ddp = new DDPClient(TestConstants.sMeteorHost, TestConstants.sMeteorPort, true);
        DDPTestClientObserver obs = new DDPTestClientObserver();
        ddp.addObserver(obs);                    
        // make connection to Meteor server
        ddp.connect();          

        // we need to wait a bit before the socket is opened but make sure it's successful
        Thread.sleep(500);
        assertTrue(obs.mDdpState == DDPSTATE.Connected);

        // try disconnect
        ddp.disconnect();
    }
}
