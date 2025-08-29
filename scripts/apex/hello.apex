// Create test records
Account a1 = new Account(Name='Test Account 1');
Account a2 = new Account(Name='Test Account 2');
insert new List<Account>{a1, a2};

// Build JSON payload
List<Map<String, Object>> updates = new List<Map<String, Object>>();

// Valid update
updates.add(new Map<String, Object>{
    'sObjectType' => 'Account',
    'recordIds' => new List<Id>{a1.Id},
    'fields' => new Map<String, String>{ 'Name' => 'Updated Account 1', 'BillingCountryCode' => 'US'  }
});

// Invalid update (simulate partial failure)
updates.add(new Map<String, Object>{
    'sObjectType' => 'Account',
    'recordIds' => new List<Id>{Id.valueOf('001000000000000AAA')}, // invalid Id
    'fields' => new Map<String, String>{ 'Name' => 'Invalid Account' }
});

String jsonPayload = JSON.serialize(updates);

// Set REST context
RestRequest req = new RestRequest();
req.requestBody = Blob.valueOf(jsonPayload);
req.httpMethod = 'POST';
RestContext.request = req;
RestContext.response = new RestResponse();

// Call the REST method
RestSObjectHandler.processExternalData();

// Inspect the response
System.debug('Status Code: ' + RestContext.response.statusCode);
System.debug('Response Body: ' + RestContext.response.responseBody.toString());

// Query the updated record to verify
Account updatedA1 = [SELECT Name FROM Account WHERE Id = :a1.Id];
System.debug('Updated Account Name: ' + updatedA1.Name);

