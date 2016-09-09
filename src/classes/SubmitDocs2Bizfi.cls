public class SubmitDocs2Bizfi implements SubmitDealIF, Queueable, Database.AllowsCallouts {

    
    private McaApp__Submission__c submission;
    
    public SubmitDocs2Bizfi(){}
    
    public void submitRecord(McaApp__Submission__c newSubmission) {
        this.submission = newSubmission;
    }
	
    public void execute(QueueableContext context) {/*
        Id qbSubmission = submission.Id;
        McaApp__Submission__c subUpdate = [SELECT Name, External_Id__c, McaApp__Opportunity__c, McaApp__Opportunity__c.Name, Docs_Submitted__c FROM McaApp__Submission__c WHERE Id = :qbSubmission LIMIT 1];
        Id apiUser = [SELECT Id FROM User WHERE LastName = 'API User' LIMIT 1].Id;
        Attachment[] dealDocs = [SELECT Name, Body FROM Attachment WHERE ParentId = :subUpdate.McaApp__Opportunity__c AND OwnerId != :apiUser];
        
        if(!dealDocs.isEmpty()) {
            Zippex zip = new Zippex();
            
            for(Attachment a : dealDocs) {
                zip.addFile(a.Name, a.Body, null);
            }
            
            JSONGenerator gen = JSON.createGenerator(true);
        	
            gen.writeStartObject();
            gen.writeNumberField('PartnerID', );
            gen.writeStringField('APIKey', );
            gen.writeNumberField('BizFiAppID', );
            gen.writeFieldName('BizFiDocument');
            gen.writeStartObject();
            gen.writeStringField('DocumentName', subUpdate.McaApp__Opportunity__c.Name);
            gen.writeBlobField('DocumentData', zip.getZipArchive());
            gen.writeEndObject();
            gen.writeEndObject();

            String docs = gen.getAsString();  System.debug(docs); 
            
            if(response.getStatusCode() == 201) {
            	System.debug('***Docs Successfully Submitted***');
                subUpdate.Docs_Submitted__c = true;
                update subUpdate;
            }
        }*/
    }
    
    
}