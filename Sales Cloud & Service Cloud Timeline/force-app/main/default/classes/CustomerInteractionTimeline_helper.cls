public class CustomerInteractionTimeline_helper {
    
    @AuraEnabled(cacheable=true)
    public static String getObjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        return sObjName;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isPersonAccount(Id recordId){
        //Account acc = [SELECT Id,IsPersonAccount from Account WHERE Id =:recordId];
        String query = 'SELECT Id,IsPersonAccount from Account WHERE Id =\''+recordId+'\'';
        SObject sobj = Database.query(query);
        if(String.valueOf(sobj.get('IsPersonAccount')) == 'true')
            return true;
       	else
            return false;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(String recordId){
        return [select Id,Name,CloseDate,Amount,Owner.Name,StageName,CreatedDate from Opportunity where AccountId =: recordId];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String recordId){
        return [select Id,Name,CreatedDate,Email from Contact where AccountId =: recordId];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunitiesForContact(String recordId){
        // use the contact role isPrimary field
        List<OpportunityContactRole> oppContactRoles = [SELECT Id,ContactId, OpportunityId from OpportunityContactRole where ContactId =: recordId AND IsPrimary = true];
        List<Id> oppIds = new List<Id>();
        
        for(OpportunityContactRole oppContact: oppContactRoles){
            oppIds.add(oppContact.OpportunityId);
        }
        return [select Id,Name,CloseDate,Amount,Owner.Name,StageName,CreatedDate from Opportunity where Id IN :oppIds];
    }
    
    @AuraEnabled(cacheable=true)
    public static OpportunityTWrapper getOppotunitiesData(String recordId){
        List<OpportunityStage_Tracker__c> stageChanges = [SELECT Id,Current_Stage__c,Previous_Stage__c,Change_Date_and_Time__c,Name from OpportunityStage_Tracker__c where Name = :recordId ORDER BY Change_Date_and_Time__c ASC];
        List<FeedItem> oppFeedItems = [SELECT Id,Title,Body,ParentId,CreatedDate from FeedItem WHERE Type = 'TextPost' and ParentId =: recordId];
        List<OpportunityLineItem> oppProductsLineItems = [SELECT Id,OpportunityId,Product2Id,Product2.Name,Quantity,CreatedDate from OpportunityLineItem Where OpportunityId = :recordId];
        OpportunityTWrapper obj = new OpportunityTWrapper();
        obj.stageChange = stageChanges;
        obj.feedItems = oppFeedItems;
        obj.oppProducts = oppProductsLineItems;
        return obj;
    }
    
    public class OpportunityTWrapper{
        @AuraEnabled
        public List<OpportunityStage_Tracker__c> stageChange;
        @AuraEnabled
        public List<FeedItem> feedItems;
        @AuraEnabled
        public List<OpportunityLineItem> oppProducts;
        
    }
}