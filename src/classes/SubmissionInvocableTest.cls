@isTest
private class SubmissionInvocableTest {

    
    @isTest
    static void test_pos_invocable() {
        
        // This test just ensures the invocable class will run.
        // If we were to have an active process or trigger then
        // inserting the record would be sufficient, as in the above test method.
        // If not, then this method will be sufficient for code coverage.
        // 
        // However, do note that trying to do both in the same test will fail.
        // Trying to insert a record and call the invocable class will fail
        // because the invocable class calls a @Future method that makes an HttpCallout.
        // DML operations don't mix with HttpCallouts due to uncommitted work:
        // "System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out.""

        Integer code = 200;
        String status = 'OK';
        String body = '{"successful" : "true"}';

        Map<Id, Opportunity> oldMap = SubmissionCalloutTestSetup.mapSetup(false);
        Map<Id, Opportunity> newMap = SubmissionCalloutTestSetup.mapSetup(true);

        Test.startTest();    
        Test.setMock( HttpCalloutMock.class, new RestCalloutMockHTTP(code, status, body) );   
        SubmissionInvocable.idList( oldMap, newMap ); 
        Test.stopTest();
        
        Callout_Error__c[] ceList = [SELECT Name, Status__c, Status_Code__c, Response_Body__c FROM Callout_Error__c];
        System.assert(ceList.isEmpty());
    }

    @isTest
    static void test_neg_invocable() {

        Callout_Settings__c cs = new Callout_Settings__c();
        cs.ASAP__c = true;
        insert cs;

        Integer code = 401;
        String status = 'ERROR';
        String body = '{"successful" : "false"}';

        Map<Id, Opportunity> oldMap = SubmissionCalloutTestSetup.mapSetup(false);
        Map<Id, Opportunity> newMap = SubmissionCalloutTestSetup.mapSetup(true);
        
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new RestCalloutMockHTTP(code, status, body) );
        SubmissionInvocable.idList( oldMap, newMap );
        Test.stopTest();

        Callout_Error__c[] ceList = [SELECT Status__c, Status_Code__c, Response_Body__c FROM Callout_Error__c];
        System.assert(!ceList.isEmpty());
        for(Callout_Error__c ce : ceList){
            System.assertEquals(ce.Status_Code__c, code);
            System.assertEquals(ce.Status__c, status);
            System.assertEquals(ce.Response_Body__c, body);
        }       
    }

    @isTest
    static void test_Pos_Submission() {

        String body = SubmissionCalloutTestSetup.jsonSetup();

        Integer code = 200;
        String status = 'OK';
        String resBody = '{"successful" : true}';
        String url = 'https://SubmitToBizfiFunding.bizfifunding.com';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestCalloutMockHTTP(code, status, resBody));
        HttpResponse res = APICallout.PostCall(url, body);
        Test.stopTest();

        System.assertEquals(code, res.getStatusCode());
        System.assertEquals(status, res.getStatus());
        System.assertEquals(resBody, res.getBody());
    }

    @isTest
    static void test_Neg_Submission() {

        String body = SubmissionCalloutTestSetup.jsonSetup();

        Integer code = 401;
        String status = 'ERROR';
        String resBody = '{"successful" : false}';
        String url = 'https://SubmitToBizfiFunding.bizfifunding.com';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestCalloutMockHTTP(code, status, resBody));
        HttpResponse res = APICallout.PostCall(url, body);
        Test.stopTest();

        System.assertEquals(code, res.getStatusCode());
        System.assertEquals(status, res.getStatus());
        System.assertEquals(resBody, res.getBody());
    }
    
}