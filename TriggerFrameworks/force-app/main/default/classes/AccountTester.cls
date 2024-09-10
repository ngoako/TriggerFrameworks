@isTest
public with sharing class AccountTester {
    @isTest
    public static void updateRatingTest(){
        List<Account> lstAcc = new List<Account>();
        for(Integer x = 1; x <+ 5; x++){
            Account acc = new Account();
            acc.Name = 'MondayTech';
            acc.Phone = '0987654321';
            acc.Industry = 'Banking';
            acc.AnnualRevenue = 570000;
            acc.RecordTypeId = '0128d000001ODfvAAG';

            lstAcc.add(acc);
        }
        //Add data
        Test.startTest();
            insert lstAcc;
        Test.stopTest();
        
        //Retrieve data
        List<Account> listAccount = [SELECT Id, Rating FROM Account WHERE Id =: lstAcc[0].Id];

        //Compare data
        System.assertEquals('Hot', listAccount[0].Rating);

    }

    @isTest
    public static void copyBillingToShippingTest(){
        //Create data
        List<Account> listAcc = new List<Account>();
        for(Integer x = 1; x <= 5; x++){
            Account acc = new Account();
            acc.Name = 'YouTube';
            acc.AnnualRevenue = 460000;
            acc.RecordTypeId = '0128d000001ODfvAAG';
            acc.Industry = 'Banking';
            acc.Phone = '9876543210';
            acc.BillingCity = 'Varanasi';
            acc.BillingCountry = 'India';
            acc.BillingState = 'Pretoria';
            acc.BillingStreet = '02 Carnarvon';
            acc.BillingPostalCode = '7803';
            acc.Match_Billing_Address__c = true;

            listAcc.add(acc);
        }
        //Add data
        Test.startTest();
            insert listAcc;
        Test.stopTest();

        //Retrieve data
        List<Account> lstAccount = [SELECT Id, Match_Billing_Address__c FROM Account WHERE Id =: listAcc[0].Id];

        //Compare data
        System.assertEquals(true, lstAccount[0].Match_Billing_Address__c);
    }

    @isTest
    public static void createRelatedContactTest(){
        //Create data
        List<Account> listAcc = new List<Account>();
        for(Integer x = 1; x <= 5; x++){
            Account acc = new Account();
            acc.Name = 'Vaseline';
            acc.RecordTypeId = '0128d000001ODfvAAG';

            listAcc.add(acc);
        }

        //Add data
        Test.startTest();
            insert listAcc;
        Test.stopTest();

        //Retrieve data
        List<Contact> lstContact = [SELECT Id, LastName FROM Contact WHERE AccountId =: listAcc[0].Id];

        //Compare data
        System.assert(lstContact != null, 'Contact was not created');
    }

    @isTest
    public static void createRelatedOpportunityTest(){
        //Create data
        List<Account> listAcc = new List<Account>();
        for(Integer x = 1; x <= 5; x++){
            Account acc = new Account();
            acc.Name = 'PWC';
            acc.RecordTypeId = '0128d000001ODfvAAG';

            listAcc.add(acc);
        }

        //Add data
        Test.startTest();
            insert listAcc;
        Test.stopTest();

        //Retrieve data
        List<Opportunity> lstOpportunities = [SELECT Id, Name FROM Opportunity WHERE AccountId =: listAcc[0].Id];

        //Compare data
        System.Assert(lstOpportunities != null, 'Opportunity was not created');
    }

    @isTest
    public static void minimumAnnualRevenueTest(){
        //Create Data
        List<Account> lstAcc = new List<Account>();
        for(Integer x = 1; x <= 5; x++){
            Account acc = new Account();
            acc.Name = 'Huawei' + x;
            acc.RecordTypeId = '0128d000001ODfvAAG';
            acc.AnnualRevenue = 10000;
            lstAcc.add(acc);
        }
        //Insert data
        test.startTest();
            insert lstAcc;
        test.stopTest();
        
        //Retrieve data
        List<Account> listAccount = [SELECT Id, AnnualRevenue FROM Account WHERE Id =: lstAcc[0].Id];

        //Compare data
        System.assertEquals(10000, listAccount[0].AnnualRevenue);
    }

    @isTest
    public static void preventAccountDeletionTest(){
        //Create the test accounts
        List<Account> lstAcc = new List<Account>();
        for(Integer x = 0; x <= 5; x++){
            Account acc = new Account();
            acc.Name = 'Barcadi' + 1;
            acc.RecordTypeId = '0128d000001ODfvAAG';

            lstAcc.add(acc);
        }
        if(!lstAcc.isEmpty()){
            insert lstAcc;
        }
        //Create and insert Opportunity records associated with the accounts
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for(Account acc : lstAcc){
            Opportunity opp = new Opportunity();
            opp.Name = 'Opportunity ' + acc.Name;
            opp.CloseDate = Date.today().addDays(20);
            opp.StageName = 'Needs Analysis';
            opp.AccountId = acc.Id;
            testOpportunities.add(opp);
        }
        //insert the opportunitties
        insert testOpportunities;

        //Try to delete the accounts
        test.startTest();
        try {
            delete lstAcc;
            System.assert(false,'Account should not be deletable when associated with an account');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot delete account with existing opportunities'), 'Expected exception was not thrown');
        }
        test.stopTest();

    }

    @isTest
    public static void accountAfterDeletionTest(){
        List<Account> lstAccount = new List<Account>();
        for(Integer x = 0; x <= 5; x++){
            Account acc = new Account();
            acc.Name = 'Stella' + 1;
            acc.RecordTypeId = '0128d000001ODfvAAG';

            lstAccount.add(acc);
        }
        if(!lstAccount.isEmpty()){
            insert lstAccount;
        }

        try {
            delete lstAccount;
            System.assert(true, 'Account was deleted');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot delete account'), 'Expected exception was not thrown');
        }
    }
}