public with sharing class AccountHelper {
    //Make rating to be HOT when the annual revenue on the account is greater or eqaul to 500000
    public static void updateRating(List<Account> lstAccount){
        if(!lstAccount.isEmpty()){
            for(Account acc : lstAccount){
                List<Account> listAcc = new List<Account>();
                if(acc.AnnualRevenue >= 500000){
                    acc.Rating = 'Hot';
                    listAcc.add(acc);
                }
            }
        }
    }
    //Copy billing address to shipping address when the Match_Billing_Address__c checkbox is true
    public static void copyBillingToShipping(List<Account> lstAccount){
        if(!lstAccount.isEmpty()){
                for(Account acc : lstAccount){
                    List<Account> listAcc = new List<Account>();
                    if(acc.Match_Billing_Address__c == true && acc.BillingCity != null){
                        acc.ShippingCity = acc.BillingCity;
                        acc.ShippingCountry = acc.BillingCountry;
                        acc.ShippingState = acc.BillingState;
                        acc.ShippingStreet = acc.BillingStreet;
                        acc.ShippingPostalCode = acc.BillingPostalCode;
                    }
                }
        }
    }
    //Create a related Contact when a new Account is created
    public static void createRelatedContact(List<Account> accList){
        if(!accList.isEmpty()){
            List<Contact> listContact = new List<Contact>();
            for(Account acc : accList){
                Contact con = new Contact();
                con.FirstName = acc.Name +' Masta';
                con.LastName = 'Masekela';
                con.Email = acc.Name + String.valueOf(acc.Id).substring(0, 5) + '@gmail.com'; //Use part of the Account Id for uniqueness
                con.Phone = '0147852026';
                con.RecordTypeId = '0128d000001ODgBAAW';

                con.AccountId = acc.Id;
                listContact.add(con);
            }
            if(!listContact.isEmpty()){
                insert listContact;
            }
        }
    }
    //When an Account record is created the create a related Opportunity
    public static void createRelatedOpportunity(List<Account> listAccount){
        if(!listAccount.isEmpty()){
            List<Opportunity> lstOpp = new List<Opportunity>();
            for(Account acc : listAccount){
                Opportunity opp = new Opportunity();
                opp.Name = 'Festival';
                opp.CloseDate = system.today().addDays(20);
                opp.StageName = 'Prospecting';

                opp.AccountId = acc.Id;
                lstOpp.add(opp);
            }
            if(!lstOpp.isEmpty()){
                insert lstOpp;
            }
        }
    }
    /*Ensure that an account's AnnualRevenue is never set below a 10,000 threshold. 
    If the user tries to set it lower, set it back to be default 10,000. */
    public static void minimumAnnualRevenue(Map<ID,Account> mapAccount){
        if(!mapAccount.isEmpty()){
            for(Account acc : mapAccount.values()){
                if(acc.AnnualRevenue < 10000){
                    acc.AnnualRevenue = 10000;
                }
            }
        }
    }
    /*
         checks if the AnnualRevenue of an account has changed, and if so, it logs the change 
         in a custom object called AccountRevenueLog__c.
    */
    public static void annualRevennueChange(Map<ID,Account> mapAccount, Map<Id, Account> oldMap){
        if(!mapAccount.isEmpty()){
            List<AccountRevenueLog__c> revenueLogs = new List<AccountRevenueLog__c>();
            for(Account acc : mapAccount.values()){
                //Get the old version of the account
                Account oldAcc = oldMap.get(acc.Id);

                //Check if annual revenue has changed
                if(acc.AnnualRevenue != oldAcc.AnnualRevenue){
                    //Create a new log entry for the revenue change
                    AccountRevenueLog__c log = new AccountRevenueLog__c();
                    log.Account__c = acc.Id; //Link the log to the account
                    log.Old_Value__c = oldAcc.AnnualRevenue;
                    log.New_Value__c = acc.AnnualRevenue;
                    log.Change_Date__c = System.now();//record the date of change
                    log.ChangedBy__c = UserInfo.getUserId();//Record the user who made the change

                    revenueLogs.add(log);
                }

                if(!revenueLogs.isEmpty()){
                    insert revenueLogs;
                }

            }
        }
    }
    /*
        Prevent deletion of an Account if it has any associated Opportunities
    */
    public static void preventAccountDeletion(Map<ID, Account> oldMapAcc){
        //Collect the unique Account records
        if(!oldMapAcc.isEmpty()){
            Set<Account> setAcc = new Set<Account>();
            for(Account acc : oldMapAcc.values()){
                setAcc.add(acc);
            }
            //collect the opportunities that belong to an account
            List<Opportunity> listOpp = [SELECT Id FROM Opportunity WHERE AccountId IN : setAcc];

            //Verify the deletion
            if(!listOpp.isEmpty()){
                for(Account acc : oldMapAcc.values()){
                    acc.addError('Cannot delete account with existing opportunities');
                }
            }
        }
    }
    /*
        After deleting an account, log the deletion in a custom object AccountDeletion__c with details like Account name and deletion time
    */
    public static void accountAfterDeletion(Map<Id,Account> OldMap){
        if(!OldMap.isEmpty()){
            List<AccountDeletion__c> deletedList = new List<AccountDeletion__c>();
            for(Account acc : OldMap.values()){
                AccountDeletion__c log = new AccountDeletion__c();
                log.Account_Name__c = acc.Name;
                log.Deletion_Date__c = System.now();
                
                deletedList.add(log);
            }

            if(!deletedList.isEmpty()){
                insert deletedList;
            }
        }
    }
    /*
        When an account is undeleted, set the Account status field to Reactivated and send a notification email to an account owner
    */
    public static void accountAfterUndelete(List<Account> listNew){
        if(!listNew.isEmpty()){
            // Query the modifiable accounts from the database
            List<Account> modifiableAccounts = [SELECT Id, Name, Status__c, Owner.Email FROM Account WHERE Id IN :listNew];
       

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(Account acc : modifiableAccounts){
                acc.Status__c = 'Reactivated';

                //Setup an email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {acc.Owner.Email});
                email.setSubject('Account Reactivated');
                email.setPlainTextBody('The account "' + acc.Name + '" has been reactivated.');

                emails.add(email);
            }
            if(!emails.isEmpty()){
                Messaging.sendEmail(emails);
            }
            if(!modifiableAccounts.isEmpty()){
                update modifiableAccounts;
            }
        }
    }
}