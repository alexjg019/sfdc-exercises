/**
 * Created By: Alex Gaskin
 * Date: 2025-08-27
 * Function: 
 *
 * Modification Log:
 * Name           Ticket   Date        Description
 * -------------------------------------------------------------------------------------------------
 * Alex Gaskin    N/A      2025-08-27  Initial creation
 * -------------------------------------------------------------------------------------------------
 */

@isTest
private class RestSObjectHandlerTest {

    @isTest
    static void testProcessExternalData() {
        Account a1 = new Account(Name='Test Account 1');
        Account a2 = new Account(Name='Test Account 2');
        insert new List<Account>{a1, a2};

        // JSON payload
        List<Map<String, Object>> updates = new List<Map<String, Object>>();

        // Successful update
        updates.add(new Map<String, Object>{
            'sObjectType' => 'Account',
            'recordIds' => new List<Id>{a1.Id},
            'fields' => new Map<String, String>{ 'Name' => 'Updated Account 1' }
        });

        // Partial failure
        updates.add(new Map<String, Object>{
            'sObjectType' => 'Account',
            'recordIds' => new List<Id>{a2.Id},
            'fields' => new Map<String, String>{ 'Name' => null }
        });

        String jsonPayload = JSON.serialize(updates);

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonPayload);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        RestSObjectHandler.processExternalData();
        Test.stopTest();

        RestResponse res = RestContext.response;
        System.assertEquals(400, res.statusCode, 'Partial failure should return 400');
        System.assert(res.responseBody.toString().contains('partial_failure'), 'Response should indicate partial failure');

        a1 = [SELECT Name FROM Account WHERE Id = :a1.Id];
        System.assertEquals('Updated Account 1', a1.Name, 'Account name should be updated');
    }

    @isTest
    static void testEmptyPayload() {
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('[]');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        RestSObjectHandler.processExternalData();
        Test.stopTest();

        RestResponse res = RestContext.response;
        System.assertEquals(400, res.statusCode, 'Empty updates should return 400');
        System.assert(res.responseBody.toString().contains('No updates provided'), 'Response should indicate no updates');
    }
}
