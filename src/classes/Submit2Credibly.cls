global class Submit2Credibly extends SubmitDealVirtual implements Queueable, Database.AllowsCallouts{


	public Submit2Credibly(){}

	public override void setSubmission(McaApp__Submission__c newSubmission){
		super.setSubmission(newSubmission);
	}

	global void execute(QueueableContext context) {}


}