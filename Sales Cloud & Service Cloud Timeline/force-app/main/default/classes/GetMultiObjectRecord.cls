public with sharing class GetMultiObjectRecord {
    @AuraEnabled(cacheable=true)
    public static Wrapper getRecords(String recId){
        String sObjName = Id.valueOf(recId).getSObjectType().getDescribe().getName();
        Wrapper wrapperObject = new Wrapper();
        wrapperObject.recordId = recId;
        wrapperObject.sObjectType = sObjName;
        wrapperObject.getContactId();
        wrapperObject.getCases();
        wrapperObject.getEmails();
        wrapperObject.getTasks();
        
        if(SObjectUtil.isObjectExist('LiveChatTranscript'))
            wrapperObject.getChatTranscripts();
        if(SObjectUtil.isObjectExist('MessagingSession'))
            wrapperObject.getConversationEntries();
        if(SObjectUtil.isObjectExist('SocialPost'))
            wrapperObject.getSocialPosts();
        return wrapperObject;
    }
    public class Wrapper{
        @AuraEnabled
        public String sObjectType;
        @AuraEnabled
        public Id recordId;
        public List<Id> caseIds = new List<Id>();
        
        @AuraEnabled
        public list<Case> caseList {get;set;}
        @AuraEnabled
        public list<SObject> messagingList = new List<SObject>();
        @AuraEnabled
        public list<SObject> chatsList = new List<SObject>();
        @AuraEnabled
        public String transcriptCompiler ='';
        @AuraEnabled
        public list<messagingWrapper> messaging = new List<messagingWrapper>();
        @AuraEnabled
        public list<Task> emailMessages;
        @AuraEnabled
        public List<Task> callTasks;
        @AuraEnabled
        public List<SObject> socialPosts = new List<SObject>();
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public String leadId;
        @AuraEnabled
        public Boolean remainingRecords = false;
        
        public String caseId = '';
        
        public void getContactId() {
            if(sObjectType == 'Case') {
                List<String> fieldNames = new List<String>{'ContactId'};
                    String objName = 'Case';
                if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                    contactId = [SELECT ContactId FROM Case WHERE Id =: this.recordId LIMIT 1].ContactId;
                }
                else{
                    contactId = '';
                }
                
                this.leadId = '';
            } else if(sObjectType == 'LiveChatTranscript') {
                
                List<String> fieldNames = new List<String>{'ContactId'};
                    String objName = 'LiveChatTranscript';
                if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                    String query= 'SELECT ContactId From LiveChatTranscript WHERE Id =\''+String.valueOf(this.recordId)+'\' LIMIT 1';
                    SObject chatContact = Database.query(query);
                    contactId = String.valueOf(chatContact.get('ContactId'));
                }else{
                    contactId = '';
                }
                
                this.leadId = '';
            }
            else if(sObjectType == 'Task') {
                
                List<String> fieldNames = new List<String>{'WhoId'};
                    String objName = 'Task';
                if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                    contactId = [SELECT WhoId From Task WHERE Id =: this.recordId LIMIT 1].WhoId;
                }else{
                    contactId = '';
                }
                
                this.leadId = '';
            } else if(sObjectType == 'MessagingSession') {
                
                List<String> fieldNames = new List<String>{'EndUserContactId'};
                    String objName = 'MessagingSession';
                if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                    String query1= 'SELECT EndUserContactId From MessagingSession WHERE Id =\''+String.valueOf(this.recordId)+'\' LIMIT 1';
                    SObject messagingContact = Database.query(query1);
                    contactId = String.valueOf(messagingContact.get('EndUserContactId'));
                }else{
                    contactId = '';
                }
                
                this.leadId = '';
            }
            else if(sObjectType == 'Contact'){
                
                List<String> fieldNames = new List<String>{'Id'};
                    String objName = 'Contact';
                if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                    contactId = [SELECT Id FROM Contact WHERE Id =: this.recordId LIMIT 1].Id;
                }else{
                    contactId = '';
                }
                
                this.leadId = '';
            }
            else if(sObjectType == 'SocialPost'){
                
                List<String> fieldNames = new List<String>{'WhoId'};
                    String objName = 'SocialPost';
                if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                    String query2 = 'SELECT WhoId From SocialPost WHERE Id =\''+String.valueOf(this.recordId)+'\' LIMIT 1';
                    SObject socialPostContact = Database.query(query2);
                    contactId = String.valueOf(socialPostContact.get('WhoId'));
                }else{
                    contactId = '';
                }
                
                this.leadId = '';
            }
            else if(sObjectType == 'Account'){
                //contactId = [SELECT PersonContactId from Account where Id =: this.recordId LIMIT 1].PersonContactId;
                List<String> fieldNames = new List<String>{'PersonContactId'};
                    String objName = 'Account';
                if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                    String query3 = 'SELECT PersonContactId from Account where Id =\''+this.recordId+'\'this.recordId LIMIT 1';
                    SObject personAccount = Database.query(query3);
                    contactId = String.valueOf(personAccount.get('PersonContactId'));
                }
                else{
                    contactId = '';
                }
                
                this.leadId = '';
            }
            else if(sObjectType == 'Lead'){
                leadId = this.recordId;
                contactId = '';
            }
        } 
        
        
        public  void getCases(){
            if(this.contactId != ''){
                List<String> fieldNames = new List<String>{'CaseNumber','Subject','Description','CreatedDate','OwnerId','Status','ContactId'};
                    String objName = 'Case';
                if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                    caseList = [SELECT id,CaseNumber,Subject,Description,CreatedDate,Owner.Name,Status from Case where ContactId =: contactId ORDER BY CreatedDate DESC];
                }
                else{
                    caseList = new List<Case>();
                }
            }
            else
                caseList = new List<Case>();
        }
        
        public void getSocialPosts(){
            if(SObjectUtil.isObjectExist('SocialPost')){
                List<String> fieldNames = new List<String>{'Name','ParentId','MessageType','CreatedDate','Content','WhoId'};
                    String objName = 'SocialPost';
                String getSocialPostsQuery = 'select id,Name,Parent.Name,MessageType,CreatedDate,Content,Who.Name from SocialPost where WhoId =\'';
                
                if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                    if(this.contactId != ''){
                        socialPosts = Database.query(getSocialPostsQuery + this.contactId + '\'');
                    }
                    else if(this.leadId != ''){
                        socialPosts = Database.query(getSocialPostsQuery + this.leadId + '\'');
                    }
                }else{
                    socialPosts = new List<SObject>();
                }
                
            }
        }
        
        public  void getChatTranscripts(){
            if(SObjectUtil.isObjectExist('LiveChatTranscript')){
                String getChatsQuery = 'SELECT id,CaseId,Name,UserAgent,Body,StartTime,ContactId,Contact.Name,CreatedDate from LiveChatTranscript where ';
                List<String> fieldNames = new List<String>{'CaseId','Name','UserAgent','Body','StartTime','ContactId','CreatedDate'};
                    String objName = 'LiveChatTranscript';
                if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                    if(this.contactId != '')
                        chatsList = Database.query(getChatsQuery + 'ContactId = \'' + this.contactId + '\' ORDER BY StartTime DESC');
                    else if(this.leadId != ''){
                        List<String> leadFields = new List<String>{'LeadId'};
                            if(FLSCheck_apex.isAccessible(leadFields, objName))
                            chatsList = Database.query(getChatsQuery + 'LeadId = \'' + this.leadId + '\' ORDER BY StartTime DESC');
                        else
                            chatsList = new List<SObject>();
                    }
                }else{
                    chatsList = new List<SObject>();
                }
                
            }
        }
        
        
        public void getConversationEntries() {
            if(SObjectUtil.isObjectExist('MessagingSession')){
                
                //String getConvQuery = 'SELECT ActorName,ActorType,EntryType,Message,ConversationId,CreatedDate FROM ConversationEntry WHERE EntryType = \'Text\' AND ConversationId IN :messagingListIds ORDER BY CreatedDate ASC';
                List<String> fieldNames = new List<String>{'CaseId','Name','ChannelName','ChannelType','StartTime','EndUserAccountId','CreatedDate','OwnerId','EndUserContactId','MessagingEndUserId'};
                    String objName = 'MessagingSession';
                List<String> fieldNames1 = new List<String>{'ActorName','ActorType','EntryType','Message','ConversationId','CreatedDate'};
                    String objName1 = 'ConversationEntry';
                List<String> contactFields = new List<String>{'Name'};
                    String objName2 = 'Contact';
                
                if(FLSCheck_apex.isAccessible(fieldNames, objName) && FLSCheck_apex.isAccessible(fieldNames1, objName1) && FLSCheck_apex.isAccessible(contactFields, objName2)){
                    String query = 'SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate,MessagingEndUserId,MessagingEndUser.Contact.Name from MessagingSession where ';
                    if(this.contactId != ''){
                        if(caseId == '' && !remainingRecords){
                            this.messagingList = Database.query(query + 'EndUserContactId = \''+contactId+'\'ORDER BY StartTime DESC');   
                        }    
                        else if(caseId != '' && !remainingRecords){
                            this.messagingList = Database.query(query + 'CaseId = \''+caseId+'\'ORDER BY StartTime DESC');
                            caseIds.add(caseId);
                        }
                        else if ((caseId != '' && remainingRecords) || (caseId =='' && remainingRecords)){
                            String queryRR = 'SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate,MessagingEndUserId,MessagingEndUser.Contact.Name from MessagingSession where CaseId NOT IN :caseIds AND  EndUserContactId =: contactId ORDER BY StartTime DESC';
                            this.messagingList = Database.query(queryRR);
                        }
                        getConversationItemsHelper();
                    }
                    else if(this.leadId != ''){
                        List<String> leadFields = new List<String>{'LeadId'};
                            if(FLSCheck_apex.isAccessible(leadFields, objName)){
                                String queryLead = 'SELECT id,CaseId,Name,StartTime,EndUserAccountId,ChannelName,ChannelType,EndUserAccount.Name,owner.Name,EndUserContact.Name,createddate,MessagingEndUserId,MessagingEndUser.Contact.Name from MessagingSession where CaseId NOT IN :caseIds AND  LeadId =\''+leadId+'\' ORDER BY StartTime DESC';
                                this.messagingList = Database.query(queryLead);
                                getConversationItemsHelper();
                            }
                        else{
                            this.messagingList = new List<SObject>();
                            this.transcriptCompiler = '';
                            this.messaging = new List<messagingWrapper>();
                        }
                    }      
                }else{
                    this.messagingList = new List<SObject>();
                    this.transcriptCompiler = '';
                    this.messaging = new List<messagingWrapper>();
                }
            }
        }
        
        public void getConversationItemsHelper(){
            List<String> messagingListIds = new List<String>();
            for(Integer i=0;i< this.messagingList.size();i++){
                messagingListIds.add(String.valueOf(messagingList[i].get('id')));
            }
            String getConvQuery = 'SELECT ActorName,ActorType,EntryType,Message,ConversationId,CreatedDate FROM ConversationEntry WHERE EntryType = \'Text\' AND ConversationId IN :messagingListIds ORDER BY CreatedDate ASC';
            List<SObject> messageEntry = Database.query(getConvQuery);
            
            Map<String,List<SObject>> messageEntryMap = new Map<String,List<SObject>>();
            
            for(Integer i=0;i<messageEntry.size();i++){
                String key = String.valueOf(messageEntry[i].get('ConversationId'));
                if(messageEntryMap.keySet().contains(key)){
                    List<SObject> correspondingList = messageEntryMap.get(key);
                    correspondingList.add(messageEntry[i]);
                    messageEntryMap.put(key,correspondingList);
                }
                else{
                    List<SObject> newList = new List<SObject>();
                    newList.add(messageEntry[i]);
                    messageEntryMap.put(key,newList);
                }
            }
            for(Integer i=0;i< this.messagingList.size();i++){
                List<SObject> messageEntryItems = messageEntryMap.get(String.valueOf(messagingList[i].get('Id')));
                if(messageEntryItems != null){
                    for (Sobject entry : messageEntryItems) {
                        if (String.valueOf(entry.get('ActorType')) == 'EndUser') {
                            if (String.valueOf(entry.get('Message'))==null) {
                                this.transcriptCompiler = this.transcriptCompiler +this.messagingList[i].getSObject('MessagingEndUser').getSObject('Contact').get('Name') + ': ' + '[Unsupported Object]' + '\n';
                            } else {
                                this.transcriptCompiler = this.transcriptCompiler + this.messagingList[i].getSObject('MessagingEndUser').getSObject('Contact').get('Name') + ': ' + String.valueOf(entry.get('Message')) + '\n';
                            }          
                        }
                        else if(String.valueOf(entry.get('ActorType')) == 'Agent'){
                            this.transcriptCompiler = this.transcriptCompiler + String.valueOf(entry.get('ActorType')) + ': ' + String.valueOf(entry.get('Message')) + '\n';
                        }
                        else if (String.valueOf(entry.get('ActorType')) == 'Bot'){
                            this.transcriptCompiler = this.transcriptCompiler + 'Me: ' + String.valueOf(entry.get('Message')) + '\n';
                        }
                    }
                    this.messaging.add(new messagingWrapper(this.messagingList[i],this.transcriptCompiler));
                }
            }
        }
        
        public void getEmails(){
            List<String> fieldNames = new List<String>{'Description','WhoId','Priority','Subject','Type','CreatedDate'};
                String objName = 'Task';
            if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                if(this.contactId != ''){
                    emailMessages = [SELECT Description,Who.Name,WhoId,CreatedDate,Priority,Subject FROM Task WHERE Type = 'Email' AND WhoId =: contactId];
                }
                else if(this.leadId != ''){
                    emailMessages = [SELECT Description,Who.Name,WhoId,CreatedDate,Priority,Subject FROM Task WHERE Type = 'Email' AND WhoId =: leadId];
                }
            }else{
                emailMessages = new List<Task>();
            }
            
        }
        
        public void getTasks(){
            List<String> fieldNames = new List<String>{'Description','WhoId','Subject','Type','CreatedDate','Status','ActivityDate','WhatId'};
                String objName = 'Task';
            if(FLSCheck_apex.isAccessible(fieldNames, objName)){
                if(this.contactId != ''){
                    callTasks = [select Id,Type,what.Name,who.Name,ActivityDate,Subject,Status,Description,createddate from task where Type='call' and WhoId =: contactId ORDER BY createddate DESC];
                }
                else if(this.leadId != ''){
                    callTasks = [select Id,Type,what.Name,who.Name,ActivityDate,Subject,Status,Description,createddate from task where Type='call' and WhoId =: leadId ORDER BY createddate DESC];
                }
            }else{
                callTasks = new List<Task>();   
            }
        }
        
    }
    
    public class messagingWrapper{
        @AuraEnabled 
        public SObject messagingSession;
        @AuraEnabled
        public String messagingSessionData;
        
        messagingWrapper(SObject messagingSession, String messagingSessionData){
            this.messagingSession = messagingSession;
            this.messagingSessionData = messagingSessionData;
        }
        
    }
}