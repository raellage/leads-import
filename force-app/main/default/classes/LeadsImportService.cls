public with sharing class LeadsImportService {
    
    public static List<Lead> convertData(String base64Data) {
        
        String data = JSON.deserializeUntyped(base64Data).toString();
        data = data.replaceAll('﻿', '');

        List<Lead> leadsToInsert = new List<Lead>();
        List<String> lstCSVLines = data.split('\r\n');

        List<String> csvColumns = lstCSVLines[0].split(',');

        if(!isValidModel(csvColumns)) {
            throw new ListException('O arquivo selecionado não corresponde ao modelo. Tente novamente ou baixe o modelo.');
        }

        for(Integer i = 1; i < lstCSVLines.size(); i++) {

            String csvLine = lstCSVLines[i];
            String prevLine = csvLine;
            Integer startIndex;
            Integer endIndex;
            
            while(csvLine.indexOf('"') > -1) {            
                if(startIndex == null) {
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                } else {
                    if(endIndex == null) {
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                    }
                }
                
                if(startIndex != null && endIndex != null){
                    String sub = csvLine.substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                    startIndex = null;
                    endIndex = null;
                }
            }
            
            List<String> csvRowData = new List<String>();

            for(String column : csvLine.split(',')) {

                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                csvRowData.add(column);
            }

            Lead objLead = new Lead();

            objLead.Salutation = csvRowData[0];
            objLead.FirstName = csvRowData[1];
            objLead.LastName = csvRowData[2];
            objLead.Phone = csvRowData[3];
            objLead.Email = csvRowData[4];
            objLead.LeadSource = csvRowData[5];

            // Verifica conteudo da ultima coluna
            if((csvRowData.size() - 1) == 6) {
                objLead.PRU_otherLeadOrigin__c = csvRowData[6];
            }

            leadsToInsert.add(objLead);
        }
        
        return leadsToInsert;
    }

    public static boolean isValidModel(List<String> csvColumns) {
        Boolean validModel = true;

        if(!csvColumns[0].equals('Tratamento*') || !csvColumns[1].equals('Primeiro nome*') || !csvColumns[2].equals('Sobrenome*') ||
        !csvColumns[3].equals('Telefone*') || !csvColumns[4].equals('E-mail*') || !csvColumns[5].equals('Origem do Lead*') || 
        !csvColumns[6].equals('Outra Origem do lead')) {
            validModel = false;
        }

        return validModel;
    }   
}