@IsTest
public with sharing class LeadsImportTest {
    
    @TestSetup
    static void makeData() {
        ContentVersion arquivoSucesso = new ContentVersion();
        arquivoSucesso.PathOnClient = 'arquivoSucesso';
        arquivoSucesso.Title = 'arquivoSucesso';
        // arquivoSucesso.VersionData = EncodingUtil.base64Decode('77u/VHJhdGFtZW50byosUHJpbWVpcm8gbm9tZSosU29icmVub21lKixUZWxlZm9uZSosRS1tYWlsKixPcmlnZW0gZG8gTGVhZCosT3V0cmEgT3JpZ2VtIGRvIGxlYWQNClNyLixJc3JhZWwsTGFnZSwxMTk2NDAxMTYxMCxpc3JhZWwubGFnZUBhY2NlbnR1cmUuY29tLExpbmtlZEluLFRlc3RlIE9yaWdlbQ0KU3IuLElzcmFlbCxMYWdlLDExOTY0MDExNjEwLGlzcmFlbC5sYWdlQGFjY2VudHVyZS5jb20sTGlua2VkSW4sVGVzdGUgT3JpZ2Vt');
        arquivoSucesso.VersionData = EncodingUtil.base64Decode('77u/VHJhdGFtZW50byosUHJpbWVpcm8gbm9tZSosU29icmVub21lKixUZWxlZm9uZSosRS1tYWlsKixPcmlnZW0gZG8gTGVhZCosT3V0cmEgT3JpZ2VtIGRvIGxlYWQNClNyLixJc3JhZWwsTGFnZSwxMTk2NDAxMTYxMCxpc3JhZWwubGFnZUBhY2NlbnR1cmUuY29tLExpbmtlZEluLCJUZXN0ZSwgT3JpZ2VtIg0KU3IuLElzcmFlbCxMYWdlLDExOTY0MDExNjEwLGlzcmFlbC5sYWdlQGFjY2VudHVyZS5jb20sTGlua2VkSW4sIlRlc3RlLCBPcmlnZW0i');
        insert arquivoSucesso;

        ContentVersion arquivoDuplicado = new ContentVersion();
        arquivoDuplicado.PathOnClient = 'arquivoDuplicado';
        arquivoDuplicado.Title = 'arquivoDuplicado';
        arquivoDuplicado.VersionData = EncodingUtil.base64Decode('77u/VHJhdGFtZW50byosUHJpbWVpcm8gbm9tZSosU29icmVub21lKixUZWxlZm9uZSosRS1tYWlsKixPcmlnZW0gZG8gTGVhZCosT3V0cmEgT3JpZ2VtIGRvIGxlYWQNClNyLixJc3JhZWwsTGFnZSwxMTk2NDAxMTYxMCxpc3JhZWwubGFnZUBhY2NlbnR1cmUuY29tLExpbmtlZEluLFRlc3RlIE9yaWdlbQ0KU3IuLElzcmFlbCxMYWdlLDExOTY0MDExNjEwLGlzcmFlbC5sYWdlQGFjY2VudHVyZS5jb20sTGlua2VkSW4sVGVzdGUgT3JpZ2Vt');
        insert arquivoDuplicado;

        ContentVersion arquivoErroFormato = new ContentVersion();
        arquivoErroFormato.PathOnClient = 'arquivoErroFormato';
        arquivoErroFormato.Title = 'arquivoErroFormato';
        arquivoErroFormato.VersionData = EncodingUtil.base64Decode('77u/Tm9tZSxUZWxlZm9uZSxFLW1haWwNCkFuYSBTaWx2YSwxMTExMTExMTEsdGVzdGUxQHRlc3RlLmNvbQ0KSm/Do28gU291emEsMjIyMjIyMjIyLHRlc3RlMkB0ZXN0ZS5jb20NCk1hcmlhIEdvbWVzLDMzMzMzMzMzMyx0ZXN0ZTNAdGVzdGUuY29tDQpDbGFyYSBOdW5lcyw0NDQ0NDQ0NDQsdGVzdGU0QHRlc3RlLmNvbQ0KUGF1bG8gVGF2YXJlcywzMzMzMzMwMDAwMDAsdGVzdGU1QHRlc3RlLmNvbQ0KTHVjaWEgT2xpdmVpcmEsNjEyMzQ1NTU2Nix0ZXN0ZTZAdGVzdGUuY29tDQpDYXJsb3MgTWFjaGFkbyw3Nzc3Nzc3Nzc3LHRlc3RlN0B0ZXN0ZS5jb20NCkVkdWFyZG8gQ29zdGEsODg4ODg4ODg4LHRlc3RlOEB0ZXN0ZS5jb20NCkp1bGlhbmEgRmVycmVpcmEsOTk5OTk5OTk5OTk5LHRlc3RlOUB0ZXN0ZS5jb20NCg==');
        insert arquivoErroFormato;      
    }

    @IsTest
    static void convertFileSuccess() {
        ContentVersion objContentVersion = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE Title =:'arquivoSucesso' LIMIT 1];
        
        Test.startTest();
        List<Lead> leads = LeadsImportController.convertFile(objContentVersion.ContentDocumentId, objContentVersion.Id);
        String mensagemSucesso = LeadsImportController.insertLeads(leads);
        Test.stopTest();
        
        System.assertEquals(2, leads.size(), 'Deve retornar 2 leads');
        System.assertEquals('Leads importados com sucesso!', mensagemSucesso, 'Deve retornar mensagem de sucesso');
    }

    @IsTest
    static void convertFileErroDuplicado() {
        Lead objLead = new Lead();
        objLead.Salutation = 'Sr.';
        objLead.FirstName = 'Israel';
        objLead.LastName = 'Lage';
        objLead.Phone = '11964011610';
        objLead.Email = 'israel.lage@accenture.com';
        objLead.LeadSource = 'Linkedin';
        objLead.PRU_otherLeadOrigin__c = 'Teste Origem';

        insert objLead;

        ContentVersion objContentVersion = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE Title =:'arquivoDuplicado' LIMIT 1];
        
        Test.startTest();
        Boolean ocorreuException = false;
        try {
            List<Lead> leads = LeadsImportController.convertFile(objContentVersion.ContentDocumentId, objContentVersion.Id);
            String mensagemSucesso = LeadsImportController.insertLeads(leads);            
        } catch (Exception ex) {
            ocorreuException = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, ocorreuException, 'Deve retornar exception');
    }

    @IsTest
    static void convertFileErroFormato() {
        ContentVersion objContentVersion = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE Title =:'arquivoErroFormato' LIMIT 1];
        
        Test.startTest();
        Boolean ocorreuException = false;
        try {
            List<Lead> leads = LeadsImportController.convertFile(objContentVersion.ContentDocumentId, objContentVersion.Id);
            String mensagemSucesso = LeadsImportController.insertLeads(leads);            
        } catch (Exception ex) {
            ocorreuException = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, ocorreuException, 'Deve retornar exception');
    }
    
}
