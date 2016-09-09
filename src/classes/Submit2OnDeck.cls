global class Submit2OnDeck implements SubmitDealIF, Queueable, Database.AllowsCallouts {


    private McaApp__Submission__c submission;
    
    public Submit2OnDeck(){}
    
    public void submitRecord(McaApp__Submission__c newSubmission) {
        this.submission = newSubmission;
    }

    public void execute(QueueableContext context) {

    	Id[] cIds = new Id[]{};
    	Id subId = submission.Id;
    	McaApp__Submission__c sub = [SELECT External_Id__c, McaApp__Opportunity__c FROM McaApp__Submission__c WHERE Id = :subId LIMIT 1];
        Id oppId = sub.McaApp__Opportunity__c;
        
        Opportunity o = [SELECT Id,
                                McaApp__NSFs_avg__c,
                         		Monthly_CC_Batches__c,
                         		McaApp__Term_Requested__c,
                         		Monthly_CC_Transactions__c,
                                McaApp__Use_of_Proceeds__c,
                                McaApp__Amount_Requested__c,
                                Amt_Monthly_Bank_Deposits__c,
                         		McaApp__Average_Daily_Balance__c,
                                McaApp__Avg_Number_Bank_Deposits__c,
                                Account.Sic,
                                Account.Name, 
                                Account.Phone,
                         		Account.Website, 
                                Account.Industry,
                                Account.AnnualRevenue,
                                Account.BillingStreet, 
                                Account.BillingCity, 
                                Account.BillingState, 
                                Account.BillingPostalCode, 
                                Account.McaApp__Legal_Name__c, 
                                Account.McaApp__Type_of_Entity__c, 
                                Account.McaApp__Federal_Tax_ID_No__c,
                                Account.McaApp__Landlord_Contact_Name__c,
                                Account.McaApp__Landlord_Phone__c, 
                                Account.McaApp__Date_Business_Established__c, 
                                Account.McaApp__Years_in_Business__c FROM Opportunity WHERE Id = :oppId];

        Id primeCon;                         
        for(OpportunityContactRole ocr : [SELECT ContactId, IsPrimary FROM OpportunityContactRole WHERE OpportunityId = :oppId]) {
            cIds.add(ocr.ContactId);
            if(ocr.IsPrimary == TRUE) { primeCon = ocr.ContactId; }
        }
            
        Map<Id, Contact> cList = new Map<Id, Contact>([SELECT Id, FirstName, LastName, BirthDate, McaApp__Of_Ownership__c, McaApp__Social_Security_Number1__c, Authorize_Run_Credit__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MobilePhone, Email, Phone, Credit_Score__c FROM Contact WHERE Id IN :cIds]);
                                
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();
        gen.writeFieldName('business');
        gen.writeStartObject();
        gen.writeStringField('phone', o.Account.Phone.replaceAll('\\D',''));
        gen.writeDateField('businessInceptionDate', o.Account.McaApp__Date_Business_Established__c);
        gen.writeStringField('taxID', o.Account.McaApp__Federal_Tax_ID_No__c.replaceAll('\\D',''));
        gen.writeStringField('doingBusinessAs', o.Account.McaApp__Legal_Name__c);
        gen.writeBooleanField('contactable', true);
        gen.writeStringField('legalEntity', o.Account.McaApp__Type_of_Entity__c);
        gen.writeStringField('loanPurpose', o.McaApp__Use_of_Proceeds__c);
        gen.writeStringField('natureOfBusiness', o.Account.INdustry);
        gen.writeStringField('landLordName', o.Account.McaApp__Landlord_Contact_Name__c);
        gen.writeStringField('landLordPhone', o.Account.McaApp__Landlord_Phone__c.replaceAll('\\D',''));
        gen.writeFieldName('address');
        gen.writeStartObject();
        gen.writeStringField('city', o.Account.BillingCity);
        gen.writeStringField('addressLine1', o.Account.BillingStreet);
        gen.writeStringField('zipCode', o.Account.BillingPostalCode);
        gen.writeStringField('state', o.Account.BillingState);
        gen.writeEndObject();
        gen.writeStringField('name', o.Account.Name);
        gen.writeEndObject();
        gen.writeFieldName('owners');
        gen.writeStartArray();
        for(Contact c : cList.values()) {
        	gen.writeStartObject();
        	gen.writeDateField('dateOfBirth', c.BirthDate);
        	gen.writeStringField('ssn', c.McaApp__Social_Security_Number1__c.replaceAll('\\D',''));
        	gen.writeFieldName('homeAddress');
	        gen.writeStartObject();
	        gen.writeStringField('city', c.MailingCity);
	        gen.writeStringField('addressLine1', c.MailingStreet);
	        gen.writeStringField('zipCode', c.MailingPostalCode);
	        gen.writeStringField('state', c.MailingState);
	        gen.writeEndObject();
        	gen.writeStringField('homePhone', c.Phone.replaceAll('\\D',''));
        	gen.writeStringField('email', c.Email);
        	gen.writeNumberField('ownershipPercentage', c.McaApp__Of_Ownership__c.intValue());
        	gen.writeStringField('cellPhoneNumber', c.MobilePhone.replaceAll('\\D',''));
            String name = c.FirstName + ' ' + c.LastName;
        	gen.writeStringField('name', name);
        	gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeFieldName('selfReported');
        gen.writeStartObject();
        gen.writeNumberField('desiredLoanTerm', o.McaApp__Term_Requested__c);
		gen.writeNumberField('transactionCount', o.Monthly_CC_Transactions__c);
		gen.writeNumberField('revenue', o.Account.AnnualRevenue);
		gen.writeNumberField('averageBalance', o.McaApp__Average_Daily_Balance__c);
		gen.writeNumberField('averageCCvolume', o.Monthly_CC_Batches__c);
		gen.writeNumberField('mcaBalance', o.McaApp__Average_Daily_Balance__c);
		gen.writeNumberField('desiredLoanAmount', o.McaApp__Amount_Requested__c);
		gen.writeNumberField('personalCreditScore', cList.get(primeCon).Credit_Score__c);
        gen.writeEndObject();
        gen.writeEndObject();

        String deal = gen.getAsString();
        //System.debug(deal);
        Submission_Field__mdt onDeck = [SELECT Endpoint__c, API_Key__c, Authentication__c FROM Submission_Field__mdt WHERE DeveloperName = 'OnDeck' LIMIT 1];
        
		String pword = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(onDeck.Authentication__c));
        
        HttpResponse response = APICallout.PostCall(onDeck.Endpoint__c, deal, 'Apikey', onDeck.API_Key__c, 'Authorization', pword);

        if(response.getStatus() == 'OK') {
			OnDeck2Apex busID = OnDeck2Apex.parse(response.getBody());
			sub.External_Id__c = busID.businessID;
			System.debug('***Successfully Submitted***');

			update sub;
		} else {
			System.debug('Callout unsuccessful.  Status code:  ' + response.getStatusCode() + '.  Message is ' + response.getBody());
			Callout_Error__c ce = new Callout_Error__c(Outbound_Message__c = deal, Class__c = 'SubmissionCallout', Status__c = response.getStatus(), Status_Code__c = response.getStatusCode(), Response_Body__c = response.getBody());
			insert ce;
		}
        
    }


}