public class CustomerInteractionTimeline_helper {
	
    @AuraEnabled(cacheable=true)
    public static String getObjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        return sObjName;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isPersonAccount(Id recordId){
        Account acc = [SELECT Id,IsPersonAccount from Account WHERE Id =:recordId];
        return acc.IsPersonAccount;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(String recordId){
        return [select Id,Name,CloseDate,Amount,Owner.Name,StageName,CreatedDate from Opportunity where AccountId =: recordId];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String recordId){
        return [select Id,Name,CreatedDate,Email from Contact where AccountId =: recordId];
    }
}