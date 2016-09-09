global with sharing class SubmissionInvocable {

	//@InvocableMethod(label='Get Opportunity IDs' description='Return list of opportunity IDs from list of opportunities')
	public static void idList(Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps){

		Callout_Settings__c cs = Callout_Settings__c.getOrgDefaults();
		Boolean callEnabled = cs.ASAP__c;
		
		if(callEnabled) {

			Set<Id> ids = new Set<Id>();
				
			for(Opportunity o : newOpps.values()) {
				if((newOpps.get(o.Id).Is_Bizfi_Submission__c != oldOpps.get(o.Id).Is_Bizfi_Submission__c) && o.Is_Bizfi_Submission__c == true){
					ids.add(o.Id);
					ids.add(o.AccountId);
				}
			}

			if(!ids.isEmpty()) { restCallout(ids); }

		}

	}

	
	@future(callout=true)
	global static void restCallout(Set<Id> subList) {
		// Collections for map to be sent and contacts related to opportunity contact roles
		String url = 'https://SubmitToBizfiFunding.bizfifunding.com';
		Map<String, List<SObject>> jsonMap = new Map<String, List<SObject>>();
		List<Id> cIds = new List<Id>();
		List<Contact> cList;

		// Get accounts and opportunities and add to map
		//List<Account> accsOut = [SELECT Id, Name, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, Website, Industry, McaApp__Legal_Name__c, McaApp__Type_of_Entity__c, McaApp__Federal_Tax_ID_No__c, McaApp__Date_Business_Established__c, McaApp__Years_in_Business__c FROM Account WHERE Id IN :subList];
		List<Account> accsOut = [SELECT Id, Name, Phone, BillingAddress, Website, Industry, McaApp__Legal_Name__c, McaApp__Type_of_Entity__c, McaApp__Federal_Tax_ID_No__c, McaApp__Date_Business_Established__c, McaApp__Years_in_Business__c FROM Account WHERE Id IN :subList];
		jsonMap.put('Account', (List<SObject>)accsOut);
		Map<Id, Opportunity> oppsOut = new Map<Id, Opportunity>([SELECT Id, McaApp__Gross_monthly_Sales__c, McaApp__Credit_Card_Sales__c, Amt_Monthly_Bank_Deposits__c, Monthly_CC_Batches__c, McaApp__Avg_Number_Bank_Deposits__c, McaApp__Average_Daily_Balance__c, McaApp__NSFs_avg__c, McaApp__NDBs_avg__c, Monthly_Debt_Service__c, Campaign_Source__c, Previous_Financing_Balance__c, McaApp__Amount_Requested__c FROM Opportunity WHERE Id IN :subList]);
		jsonMap.put('Opportunity', (List<SObject>)oppsOut.values());

		// Get Contacts and add to map
		for(OpportunityContactRole ocr : [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId IN :oppsOut.keySet()]){
			cIds.add(ocr.ContactId);
		}
		cList = [SELECT FirstName, LastName, BirthDate, McaApp__Of_Ownership__c, McaApp__Social_Security_Number1__c, Authorize_Run_Credit__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MobilePhone, Email, Credit_Score__c FROM Contact WHERE Id IN :cIds];
		jsonMap.put('Contact', (List<SObject>)cList);

		// Convert list of objects into JSON
		String body = JSON.serialize(jsonMap);
		String prettyBody = JSON.serializePretty(jsonMap);

		HttpResponse response = APICallout.PostCall(url, body);

		if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
			System.debug('Callout successful.  Returned message is: ' + response.getBody());
		} else if(response.getStatusCode() >= 400) {
			System.debug('Callout unsuccessful.  Status code:  ' + response.getStatusCode() + '.  Message is ' + response.getBody());
			Callout_Error__c ce = new Callout_Error__c(Outbound_Message__c = prettyBody, Class__c = 'SubmissionCallout', Status__c = response.getStatus(), Status_Code__c = response.getStatusCode(), Response_Body__c = response.getBody());
			insert ce;
		} 
	}
	
}