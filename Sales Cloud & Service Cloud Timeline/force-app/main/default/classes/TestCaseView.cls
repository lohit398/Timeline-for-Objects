@isTest
public class TestCaseView {
    static testMethod void wrapperTestgetContactId(){
        Case c = new Case();
        c.ContactId = '0035g000002TTshAAG';
        c.Status ='New';
        c.Priority = 'Medium';
        INSERT c;
        
        Lead new_lead = new lead();
        new_lead.LastName = 'Lead';
        new_lead.FirstName = 'CIT';
        new_lead.Company = 'SF';
        INSERT new_lead;
        
        
        LiveChatTranscript l = new LiveChatTranscript();
        l.ContactId = '0035g000002TTshAAG';
        l.ChatKey = 'Z1234567890fghjk';
        l.LiveChatVisitorId = '5715g000000wnB5AAI';
        INSERT l;
        
        
        
        Task t = new Task();
        t.WhoId = '0035g000002TTshAAG';
        t.Type = 'call';
        t.Status = 'Completed';
        t.Subject = 'Inbound call on Wed, Jun 28, 2017 10:48 AM';
        INSERT t;
        
        Task t_e = new Task();
        t_e.WhoId = '0035g000002TTshAAG';
        t_e.Type = 'Email';
        t_e.Status = 'Completed';
        t_e.Subject = 'Inbound call on Wed, Jun 28, 2017 10:48 AM';
        INSERT t_e;
        
        /*MessagingSession m = new MessagingSession();
		m.EndUserContactId = '0032w00000C6g9NAAR';
		INSERT m;*/
        
        Contact cnct = new Contact();
        cnct.FirstName ='CIT';
        cnct.LastName = 'timeline';
        cnct.Email = 'lohit.b@salesforce.com';
        cnct.AccountId = '0015g000003ZMBmAAO';
        INSERT cnct;
        
        Task t_e_cnct = new Task();
        t_e_cnct.WhoId = cnct.Id;
        t_e_cnct.Type = 'Email';
        t_e_cnct.Status = 'Completed';
        t_e_cnct.WhatId = c.Id;
        t_e_cnct.Subject = 'Inbound call on Wed, Jun 28, 2017 10:48 AM';
        INSERT t_e_cnct;
        
        Task t_cnct = new Task();
        t_cnct.WhoId = cnct.Id;
        t_cnct.Type = 'call';
        t_cnct.Status = 'Completed';
        t_cnct.Subject = 'Inbound call on Wed, Jun 28, 2017 10:48 AM';
        t_cnct.WhatId = c.Id;
        INSERT t_cnct;
        
        LiveChatTranscript l_cnct = new LiveChatTranscript();
        l_cnct.ContactId = cnct.Id;
        l_cnct.ChatKey = 'Z1234567890fghjk';
        l_cnct.LiveChatVisitorId = '5715g000000wnB5AAI';
        INSERT l_cnct;
        
        Case c_cnct = new Case();
        c_cnct.ContactId = cnct.Id;
        c_cnct.Status ='New';
        c_cnct.Priority = 'Medium';
        INSERT c_cnct;    
        
        LiveChatTranscript l_case = new LiveChatTranscript();
        l_case.ContactId = cnct.Id;
        l_case.ChatKey = 'Z1234567890fghjk';
        l_case.LiveChatVisitorId = '5715g000000wnB5AAI';
        l_case.CaseId = c.Id;
        INSERT l_case;
        
        
        MessagingSession s = new MessagingSession();
        MessagingEndUser mu = new MessagingEndUser();
        mu.ContactId = cnct.Id;
        mu.Name = 'CIT';
        mu.MessagingPlatformKey = 'Test Class Key';
        mu.MessageType = 'Facebook';
        mu.MessagingChannelId = '0Mj5g000000k9diCAA';
        INSERT mu;
        s.MessagingEndUserId =  mu.Id;
        s.MessagingChannelId = '0Mj5g000000k9diCAA';
        s.Status = 'Ended';
        INSERT s;
        ConversationEntry new_entry = new ConversationEntry();
        new_entry.ActorType = 'EndUser';
        new_entry.ConversationId = s.Id;
        new_entry.Seq = 1;
        Datetime  myDateTime = Datetime.newInstance(2020, 12, 21);
        new_entry.EntryTime = myDateTime;
        new_entry.HasAttachments = false;
        new_entry.Message = 'hello';
        new_entry.MessageIdentifier = '3a570e1b-8438-45ce-9542-2e52765b6192';
        new_entry.MessageStatus = 'Delivered';
        new_entry.EntryType  = 'Text';
        
        INSERT new_entry;
        ConversationEntry new_entry_agent = new ConversationEntry();
        new_entry_agent.ActorType = 'Agent';
        new_entry_agent.ConversationId = s.Id;
        new_entry_agent.Seq = 2;
        new_entry_agent.EntryTime = myDateTime.addMinutes (1);
        //new_entry.MessageIdentifier  = 'Text';
        new_entry_agent.Message = 'hello';
        new_entry_agent.MessageIdentifier = '3a570e1b-8438-45ce-9542-2e52765b6192';
        new_entry_agent.MessageStatus = 'Delivered';
        new_entry_agent.EntryType  = 'Text';
        INSERT new_entry_agent;
        ConversationEntry new_entry_bot = new ConversationEntry();
        new_entry_bot.ActorType = 'Bot';
        new_entry_bot.ConversationId = s.Id;
        new_entry_bot.Seq = 3;
        new_entry_bot.EntryTime = myDateTime.addMinutes (2);
        //new_entry.MessageIdentifier  = 'Text';
        new_entry_bot.Message = 'hello';
        new_entry_bot.MessageIdentifier = '3a570e1b-8438-45ce-9542-2e52765b6192';
        new_entry_bot.MessageStatus = 'Delivered';
        new_entry_bot.EntryType  = 'Text';
        INSERT new_entry_bot;
        
        test.startTest();
        List<Id> case_list = new List<Id>();
        case_list.add(c.Id);
        case_list.add(c_cnct.Id);
        Id contactId = Id.valueOf('0035g000002TTshAAG');
        System.assertEquals(CaseRelatedRecords.getRelatedCases('0035g000002TTshAAG').size(), 1);
        System.assertEquals(CaseRelatedRecords.unrelatedRecords(contactId,case_list).chatsList.size(),1);
        System.assertEquals(CaseRelatedRecords.unrelatedRecords(contactId,case_list).emailMessages.size(),1);
        System.assertEquals(CaseRelatedRecords.unrelatedRecords(contactId,case_list).callTasks.size(),1);
        System.assertEquals(CaseRelatedRecords.unrelatedRecords(contactId,case_list).socialPosts.size(),0);
        System.assertEquals(CaseRelatedRecords.getRelatedRecords(c.Id).size(), 2);
        
        test.stopTest();
        
        
    }
}