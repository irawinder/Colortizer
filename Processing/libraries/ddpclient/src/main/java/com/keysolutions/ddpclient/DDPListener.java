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

import java.util.Map;

/**
 * Listener for method errors/results/updates
 * @author kenyee
 */
public class DDPListener {
    /**
     * Callback for method call with all result fields
     * @param resultFields returned results from method call
     */
    public void onResult(Map<String, Object> resultFields) {}
    
    /**
     * Callback for method's "updated" event
     * @param callId method call ID
     */
    public void onUpdated(String callId) {}
    
    /**
     * Callback for method's "ready" event (for subscriptions)
     * @param callId method call ID
     */
    public void onReady(String callId) {}
    
    /**
     * Callback for invalid subscription name errors
     * @param callId method call ID
     * @param errorFields fields holding error info
     */
    public void onNoSub(String callId, Map<String, Object> errorFields) {}
    
    /**
     * Callback for receiving a Pong back from the server
     * @param pingId ping ID (mandatory)
     */
    public void onPong(String pingId) {}
}
