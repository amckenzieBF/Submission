trigger OpportunityExperianTrigger on Opportunity (after update) {

    if ((SingleTriggerRun.opportunityTrigger || Test.isRunningTest())
        && !System.isBatch() && !System.isFuture()) {
        SingleTriggerRun.opportunityTrigger = false;
        OppIdContactUpdate.updateExpContact(Trigger.newMap, Trigger.oldMap);
        //SubmissionInvocable.idList(Trigger.newMap, Trigger.oldMap);
    }
}