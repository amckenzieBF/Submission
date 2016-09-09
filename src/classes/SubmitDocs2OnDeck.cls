public class SubmitDocs2OnDeck implements SubmitDealIF, Queueable, Database.AllowsCallouts {

    
    private McaApp__Submission__c submission;
    
    public SubmitDocs2OnDeck(){}
    
    public void submitRecord(McaApp__Submission__c newSubmission) {
        this.submission = newSubmission;
    }
	
    public void execute(QueueableContext context) {
        Id qbSubmission = submission.Id;
        McaApp__Submission__c subUpdate = [SELECT Name, External_Id__c, McaApp__Opportunity__c, Docs_Submitted__c FROM McaApp__Submission__c WHERE Id = :qbSubmission LIMIT 1];
        Id apiUser = [SELECT Id FROM User WHERE LastName = 'API User' LIMIT 1].Id;
        Attachment[] dealDocs = [SELECT Name, Body FROM Attachment WHERE ParentId = :subUpdate.McaApp__Opportunity__c AND OwnerId != :apiUser];
        Submission_Field__mdt onDeck = [SELECT Endpoint__c, API_Key__c, Authentication__c FROM Submission_Field__mdt WHERE DeveloperName = 'OnDeck' LIMIT 1];
        String pword = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(onDeck.Authentication__c));

        if(!dealDocs.isEmpty()) {
            Zippex zip = new Zippex();
            
            for(Attachment a : dealDocs) {
                zip.addFile(a.Name, a.Body, null);
            }
            
            JSONGenerator gen = JSON.createGenerator(true);
        
            gen.writeStartObject();
            gen.writeBlobField('file', zip.getZipArchive());
            gen.writeStringField('businessID', subUpdate.External_Id__c);
            gen.writeEndObject();

            String deal = gen.getAsString();  System.debug(deal);
            
            String docURL = onDeck.Endpoint__c + '/' + subUpdate.External_Id__c + '/document';  System.debug(docURL);
			HttpResponse response = APICallout.PostCall(docURL, deal, 'Apikey', onDeck.API_Key__c, 'Authorization', pword);
            System.debug(response); 
            
            if(response.getStatusCode() == 201) {
            	System.debug('***Docs Successfully Submitted***');
                subUpdate.Docs_Submitted__c = true;
                update subUpdate;
            }
        }
    }
    
    
}