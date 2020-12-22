public with sharing class CaseRelatedRecords {
    
    public class CaseWrapper {
        @AuraEnabled
        public Case c = new Case();        
        @AuraEnabled
        public list<SObject> chatsList = new List<SObject>();
        @AuraEnabled
        public list<Task> emailMessages = new List<Task>();
        @AuraEnabled
        public List<Task> callTasks = new List<Task>();
        @AuraEnabled
        public List<SObject> socialPosts = new List<SObject>();
        @AuraEnabled
        public List<GetMultiObjectRecord.messagingWrapper> messagingList = new List<GetMultiObjectRecord.messagingWrapper>();
    }
    @AuraEnabled(cacheable=true)
    public static List<Case> getRelatedCases(String contactId){
        List<String> fieldNames = new List<String>{'CaseNumber','Subject','Description','CreatedDate','OwnerId','Status','ContactId'};
            String objName = 'Case';
        if(FLSCheck_apex.isAccessible(fieldNames, objName))
            return [SELECT id,CaseNumber,Subject,Description,CreatedDate,Owner.Name,Status from Case where ContactId =: contactId ORDER BY CreatedDate DESC];
        else
            return new List<Case>();
    }
    @AuraEnabled
    public static CaseWrapper unrelatedRecords(Id contactId,List<Id> cases){
        CaseWrapper cWrapperUnrelated = new CaseWrapper();
        if(SObjectUtil.isObjectExist('LiveChatTranscript')){
            List<String> fieldNames = new List<String>{'CaseId','Name','UserAgent','Body','StartTime','ContactId','CreatedDate'};
                String objName = 'LiveChatTranscript';
            if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                String chatsListQuery = 'SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Contact.Name,CreatedDate from LiveChatTranscript where ContactId =\''+contactId+'\'AND CaseId NOT IN: cases ORDER BY StartTime DESC';
                cWrapperUnrelated.chatsList = Database.query(chatsListQuery);
            }else{
                cWrapperUnrelated.chatsList = new List<SObject>();
            }
        }
        
        List<String> emailFields = new List<String>{'Description','WhoId','Priority','Subject','Type','CreatedDate'};
            String taskObj = 'Task';
        if(FLSCheck_apex.isAccessible(emailFields, taskObj)){
            cWrapperUnrelated.emailMessages = [SELECT Description,Who.Name,WhoId,CreatedDate,Priority,Subject FROM Task WHERE Type = 'Email' AND whatId NOT IN: cases AND WhoId =: contactId];
        }else{
            cWrapperUnrelated.emailMessages = new List<Task>();
        }
        
        List<String> callFields = new List<String>{'Description','WhoId','Subject','Type','CreatedDate','Status','ActivityDate','WhatId'};
            if(FLSCheck_apex.isAccessible(emailFields, taskObj)){
                cWrapperUnrelated.callTasks = [select Id,Type,what.Name,who.Name,ActivityDate,Subject,Status,Description,createddate from task where Type='call' AND whatId NOT IN: cases AND WhoId =: contactId ORDER BY createddate DESC];
            }else{
                cWrapperUnrelated.callTasks = new List<Task>();
            }
        
        if(SObjectUtil.isObjectExist('SocialPost')){
            List<String> fieldNames = new List<String>{'Name','ParentId','MessageType','CreatedDate','Content','WhoId'};
                String objName = 'SocialPost';
            if(FLSCheck_apex.isAccessible(emailFields, taskObj)){
                String socialPostsQuery = 'select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where ParentId NOT IN :cases and WhoId = \''+contactId+'\'';
                cWrapperUnrelated.socialPosts = Database.query(socialPostsQuery);
            }else{
                cWrapperUnrelated.socialPosts = new List<SObject>();
            }
        }
        
        
        GetMultiObjectRecord.Wrapper obj = new GetMultiObjectRecord.Wrapper();
        obj.caseId = '';
        obj.caseIds = cases;
        obj.contactId = contactId;
        obj.remainingRecords = true;
        if(SObjectUtil.isObjectExist('MessagingSession')){
            obj.getConversationEntries();
        }
        cWrapperUnrelated.messagingList = obj.messaging;
        return cWrapperUnrelated;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CaseWrapper> getRelatedRecords(String recId){
        List<Id> caseIds = new List<Id>();
        GetMultiObjectRecord.Wrapper w = new GetMultiObjectRecord.Wrapper();
        w.sObjectType = Id.valueOf(recId).getSObjectType().getDescribe().getName();
        w.recordId = recId;
        w.getContactId();
        Id contactId = w.contactId;
        list<CaseWrapper> caseWrapperList = new List<CaseWrapper>();
        List <Case> caseList = getRelatedCases(contactId);
        
        for(Integer i=0;i<caseList.size();i++){
            caseIds.add(caseList[i].Id);
        }
        
        /*For Social Posts*/
        Map<String,List<SObject>> socialPostCases = new Map<String,List<SObject>>();
        List<String> socialFields = new List<String>{'Name','ParentId','MessageType','CreatedDate','Content','WhoId'};
            String socialObj = 'SocialPost';
        if(SObjectUtil.isObjectExist('SocialPost')){
        	if(FLSCheck_apex.isAccessible(socialFields, socialObj)){
                String querySocialPosts = 'select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name,ParentId from SocialPost where ParentId IN :caseIds';
                List<SObject> socialPostsList = Database.query(querySocialPosts);
                for(Integer i=0;i<socialPostsList.size();i++){
                    String key = String.valueOf(socialPostsList[i].get('ParentId'));
                    if(socialPostCases.keySet().contains(key)){
                        List<SObject> correspondingList = socialPostCases.get(key);
                        correspondingList.add(socialPostsList[i]);
                        socialPostCases.put(key,correspondingList);
                    }
                    else{
                        List<SObject> newList = new List<SObject>();
                        newList.add(socialPostsList[i]);
                        socialPostCases.put(key,newList);
                    }
                }
            }
        }
        
        
        /*For LiveChatTranscripts*/
        List<String> liveChatFields = new List<String>{'CaseId','Name','UserAgent','Body','StartTime','ContactId','CreatedDate'};
            String liveChatObj = 'LiveChatTranscript';
        Map<String,List<SObject>> chatsCases = new Map<String,List<SObject>>();
        
        if(SObjectUtil.isObjectExist('LiveChatTranscript')){
        	if(FLSCheck_apex.isAccessible(liveChatFields, liveChatObj)){
                String queryChatList = 'SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Contact.Name,CreatedDate from LiveChatTranscript where CaseId IN :caseIds ORDER BY StartTime DESC';
                List<SObject> chatList = Database.query(queryChatList);
                for(Integer i=0;i<chatList.size();i++){
                    String key = String.valueOf(chatList[i].get('CaseId'));
                    if(chatsCases.keySet().contains(key)){
                        List<SObject> correspondingList = chatsCases.get(key);
                        correspondingList.add(chatList[i]);
                        chatsCases.put(key,correspondingList);
                    }
                    else{
                        List<SObject> newList = new List<SObject>();
                        newList.add(chatList[i]);
                        chatsCases.put(key,newList);
                    }
                }
            }
        }
        
        
        /*For Email Messages*/
        List<String> emailFields = new List<String>{'Description','WhoId','Priority','Subject','Type','CreatedDate'};
            String taskObj = 'Task';
        Map<String,List<Task>> emailWithCases = new Map<String,List<Task>>();
        if(FLSCheck_apex.isAccessible(emailFields, taskObj)){
            List<Task> emailMessagesCases = [SELECT Description,Who.Name,WhoId,CreatedDate,Priority,Subject,WhatId FROM Task WHERE Type = 'Email' AND WhatId IN :caseIds];        
            for(Integer i=0;i<emailMessagesCases.size();i++){
                String key = String.valueOf(emailMessagesCases[i].WhatId);
                if(emailWithCases.keySet().contains(key)){
                    List<Task> correspondingList = emailWithCases.get(key);
                    correspondingList.add(emailMessagesCases[i]);
                    emailWithCases.put(key,correspondingList);
                }
                else{
                    List<Task> newList = new List<Task>();
                    newList.add(emailMessagesCases[i]);
                    emailWithCases.put(key,newList);
                }
            }
        }
        /* For Calls */
        List<String> callFields = new List<String>{'Description','WhoId','Subject','Type','CreatedDate','Status','ActivityDate','WhatId'};
            Map<String,List<Task>> callsWithCases = new Map<String,List<Task>>();
        
        if(FLSCheck_apex.isAccessible(callFields, taskObj)){
            List<Task> callsCases = [select Id,Type,what.Name,who.Name,ActivityDate,Subject,Status,Description,createddate from task where Type='call' and whatId IN :caseIds ORDER BY createddate DESC];
            
            for(Integer i=0;i<callsCases.size();i++){
                String key = String.valueOf(callsCases[i].WhatId);
                if(callsWithCases.keySet().contains(key)){
                    List<Task> correspondingList = emailWithCases.get(key);
                    correspondingList.add(callsCases[i]);
                    callsWithCases.put(key,correspondingList);
                }
                else{
                    List<Task> newList = new List<Task>();
                    newList.add(callsCases[i]);
                    callsWithCases.put(key,newList);
                }
            }
        }
        
        for(Case item: caseList){
            CaseWrapper cW = new CaseWrapper();
            cW.c = item;
            
            if(SObjectUtil.isObjectExist('LiveChatTranscript')){
                cW.chatsList = chatsCases.get(String.valueOf(item.Id));
            }
            if(SObjectUtil.isObjectExist('SocialPost')){
                cW.socialPosts = socialPostCases.get(String.valueOf(item.Id));
            }
            
            cW.emailMessages = emailWithCases.get(String.valueOf(item.Id));
            cW.callTasks = callsWithCases.get(String.valueOf(item.Id));
            
            GetMultiObjectRecord.Wrapper obj = new GetMultiObjectRecord.Wrapper();
            obj.caseId = item.Id;
            if(SObjectUtil.isObjectExist('MessagingSession')){
                obj.getConversationEntries();
                cW.messagingList = obj.messaging;
            }
            caseWrapperList.add(cW);            
        }
        CaseWrapper cW = new CaseWrapper();
        cW = unrelatedRecords(contactId,caseIds);
        caseWrapperList.add(cW);
        //System.debug(caseWrapperList);
        return caseWrapperList;
    }
}