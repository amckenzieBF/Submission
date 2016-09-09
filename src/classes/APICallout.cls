global with sharing class APICallout {


    global static HttpResponse PostCall(String endpoint, String body, String key1, String value1, String key2, String value2){

        String method = 'POST';
        String key = 'Content-Type';
        String value = 'application/json';

        // Prepare http callout
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader(key, value);
        request.setHeader(key1, value1);
        request.setHeader(key2, value2);
        request.setBody(body);

        Http http = new Http();
        HttpResponse res = new HttpResponse();

            
        //Send the request to MCC endpoint and catch any errors that might occur        
        try{
            res = http.send(request);
            System.debug('Sending message to external endpoint');
        } catch(CalloutException ce) {
            System.debug('Callout Error:  ' + ce.getMessage());
        } catch(Exception e) {
            System.debug('There was and error:  ' + e.getMessage());
        }

        return res;
    }

    global static HttpResponse PostCall(String endpoint, String body){

        String method = 'POST';
        String key = 'Content-Type';
        String value = 'application/json;charset=UTF-8';

        // Prepare http callout
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader(key, value);
        request.setBody(body);

        Http http = new Http();
        HttpResponse res = new HttpResponse();

            
        //Send the request to MCC endpoint and catch any errors that might occur        
        try{
            res = http.send(request);
            System.debug('Sending message to external endpoint');
        } catch(CalloutException ce) {
            System.debug('Callout Error:  ' + ce.getMessage());
        } catch(Exception e) {
            System.debug('There was and error:  ' + e.getMessage());
        }

        return res;
    }


}