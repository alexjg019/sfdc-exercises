/**
 * Created By: Alex Gaskin
 * Date: 2025-08-27
 * Function: Processes incoming JSON payloads to update multiple SObject records in bulk.
 *           Handles partial update successes for bulk updates.
 * Covered By: RestSObjectHandlerTest
 *
 * Modification Log:
 * Name           Ticket   Date        Description
 * -------------------------------------------------------------------------------------------------
 * Alex Gaskin    N/A      2025-08-27  Initial creation
 * -------------------------------------------------------------------------------------------------
 */

@RestResource(urlMapping='/bulkUpdateRecords/*')
global with sharing class RestSObjectHandler {

    @HttpPost
    global static void processExternalData() {

        RestResponse res = RestContext.response;

        String requestBody = RestContext.request.requestBody.toString();
        if (String.isBlank(requestBody)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"Request body is empty"}');
            return;
        }
        List<ExternalDataWrapper> updates = (List<ExternalDataWrapper>) JSON.deserialize(requestBody, List<ExternalDataWrapper>.class);
        if (updates.isEmpty()) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"No updates provided"}');
            return;
        }

        // Collect IDs per SObject type
        Map<String, Set<Id>> sObjectTypeToIds = new Map<String, Set<Id>>();
        for (ExternalDataWrapper u : updates) {
            if (!sObjectTypeToIds.containsKey(u.sObjectType)) {
                sObjectTypeToIds.put(u.sObjectType, new Set<Id>());
            }
            sObjectTypeToIds.get(u.sObjectType).addAll(u.recordIds);
        }

        // Query all records per type in bulk
        Map<String, Map<Id, SObject>> typeToRecords = new Map<String, Map<Id, SObject>>();
        for (String sObjectType : sObjectTypeToIds.keySet()) {
            Set<Id> ids = sObjectTypeToIds.get(sObjectType);
            if (ids.isEmpty()) continue;

            String queryStr = 'SELECT Id FROM ' + sObjectType + ' WHERE Id IN :ids';
            List<SObject> records = Database.query(queryStr);

            Map<Id, SObject> idMap = new Map<Id, SObject>();
            for (SObject rec : records) {
                idMap.put((Id)rec.get('Id'), rec);
            }
            typeToRecords.put(sObjectType, idMap);
        }

        // Apply updates
        List<SObject> recordsToUpdate = new List<SObject>();
        for (ExternalDataWrapper u : updates) {
            Map<Id, SObject> recordsMap = typeToRecords.get(u.sObjectType);
            if (recordsMap == null) continue;

            for (Id recId : u.recordIds) {
                if (recordsMap.containsKey(recId)) {
                    SObject rec = recordsMap.get(recId);
                    for (String fieldName : u.fields.keySet()) {
                        rec.put(fieldName, u.fields.get(fieldName));
                    }
                    recordsToUpdate.add(rec);
                }
            }
        }

        // Bulk update with partial success
        if (!recordsToUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(recordsToUpdate, false);

            List<String> errors = new List<String>();
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        errors.add(err.getMessage());
                    }
                }
            }

            if (!errors.isEmpty()) {
                String errorJson = '{"status":"partial_failure","errors":"' + String.join(errors, '; ') + '"}';

                res.statusCode = 400;
                res.responseBody = Blob.valueOf(errorJson);

            } else {
                res.statusCode = 200;
                res.responseBody = Blob.valueOf('{"status":"success"}');
            }
        } else {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"status":"no_records_to_update"}');
        }
    }

    global class ExternalDataWrapper {
        public String sObjectType;
        public List<Id> recordIds;
        public Map<String, String> fields;
    }
}
