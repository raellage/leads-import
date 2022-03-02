public with sharing class LeadsImportController {
    
    @AuraEnabled
    public static List<Lead> convertFile(Id documentId, Id contentVersionId) {

        try {    
            ContentVersion objContentVersion = [SELECT Id, VersionData FROM ContentVersion WHERE Id =:contentVersionId];

            Blob csvFileBody = objContentVersion.VersionData;
            System.debug('objContentVersion.VersionData: ' + EncodingUtil.base64Encode(objContentVersion.VersionData));
            String csvAsString = csvFileBody.toString();
            Database.delete(documentId);

            List<Lead> leads = LeadsImportService.convertData(JSON.serialize(csvAsString));

            return leads;
          
        } catch (ListException ex) {
            System.debug(ex);
            throw new AuraHandledException('O arquivo selecionado não corresponde ao modelo. Tente novamente ou baixe o modelo.');
        } 

    }

    @AuraEnabled
    public static String insertLeads(List<Lead> leads) {

        try {    
            Database.insert(leads, true);

            return 'Leads importados com sucesso!';
        } catch (Exception ex) {
            System.debug(ex);

            throw new AuraHandledException('Ocorreu um erro interno, entre em contato com o administrador.' + ex.getMessage());
        }

    }
}
