@isTest
public class TestContactView {
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
        t_e_cnct.Subject = 'Inbound call on Wed, Jun 28, 2017 10:48 AM';
        INSERT t_e_cnct;
        
        Task t_cnct = new Task();
        t_cnct.WhoId = cnct.Id;
        t_cnct.Type = 'call';
        t_cnct.Status = 'Completed';
        t_cnct.Subject = 'Inbound call on Wed, Jun 28, 2017 10:48 AM';
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
        
        GetMultiObjectRecord.Wrapper w = GetMultiObjectRecord.getRecords(c.Id);
        w.getContactId();
        System.assertEquals(w.contactId, '0035g000002TTshAAG');
        System.assertEquals(w.caseList.size(), 1);
        System.assertEquals(w.emailMessages.size(), 1);
        System.assertEquals(w.chatsList.size(), 1);
        System.assertEquals(w.callTasks.size(), 1);
        System.assertEquals(w.socialPosts.size(), 0);
        System.assertEquals(w.messagingList.size(), 0);
        
		GetMultiObjectRecord.Wrapper w_l = GetMultiObjectRecord.getRecords(l.Id);
        w_l.getContactId();
        System.assertEquals(w_l.contactId, '0035g000002TTshAAG');       
        System.assertEquals(w_l.chatsList.size(), 1);
        System.assertEquals(w_l.emailMessages.size(), 1);
        System.assertEquals(w_l.callTasks.size(), 1);
        System.assertEquals(w_l.socialPosts.size(), 0);
        System.assertEquals(w.messagingList.size(), 0);
        
        GetMultiObjectRecord.Wrapper w_T = GetMultiObjectRecord.getRecords(t.Id);
        w_T.getContactId();
        System.assertEquals(w_T.contactId, '0035g000002TTshAAG'); 
        System.assertEquals(w_T.leadId, '');
        System.assertEquals(w_T.callTasks.size(), 1);
        System.assertEquals(w_T.chatsList.size(), 1);
        System.assertEquals(w_T.emailMessages.size(), 1);
        System.assertEquals(w_T.socialPosts.size(), 0);

        
        GetMultiObjectRecord.Wrapper w_C = GetMultiObjectRecord.getRecords(cnct.Id);
        w_C.getContactId();
        System.assertEquals(w_C.contactId, cnct.Id);
        System.assertEquals(w_C.leadId, '');
        System.assertEquals(w_C.callTasks.size(), 1);
        System.assertEquals(w_C.chatsList.size(), 1);
        System.assertEquals(w_C.emailMessages.size(), 1);
        System.assertEquals(w_C.socialPosts.size(), 0);
        System.assertEquals(w_C.messagingList.size(), 1);
        
        
        GetMultiObjectRecord.Wrapper w_M = GetMultiObjectRecord.getRecords(s.Id);
        w_M.getContactId();
        System.assertEquals(w_M.contactId, cnct.Id);
        System.assertEquals(w_M.leadId, '');
        System.assertEquals(w_M.caseList.size(), 1);
        System.assertEquals(w_M.emailMessages.size(), 1);
        System.assertEquals(w_M.chatsList.size(), 1);
        System.assertEquals(w_M.callTasks.size(), 1);
        System.assertEquals(w_M.socialPosts.size(), 0);
        System.assertEquals(w_M.messagingList.size(), 1);
        
        
        GetMultiObjectRecord.Wrapper w_lead = GetMultiObjectRecord.getRecords(new_lead.Id);
        w_lead.getContactId();
        System.assertEquals(w_lead.contactId, '');
        System.assertEquals(w_lead.leadId, new_lead.Id);
       	System.assertEquals(w_lead.caseList.size(), 0);
        System.assertEquals(w_lead.emailMessages.size(), 0);
        System.assertEquals(w_lead.chatsList.size(), 0);
        System.assertEquals(w_lead.callTasks.size(), 0);
        System.assertEquals(w_lead.socialPosts.size(), 0);
        System.assertEquals(w_lead.messagingList.size(), 0);
        
        GetMultiObjectRecord.Wrapper w_caseView = GetMultiObjectRecord.getRecords(cnct.Id);
        w_caseView.caseId = c_cnct.Id;
        System.debug(w_caseView.caseId);
        w_caseView.remainingRecords = true;
        w_caseView.getContactId();
        System.assertEquals(w_caseView.messagingList.size(), 1);
        
        test.stopTest();
        
    }
}