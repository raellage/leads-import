import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LEADS_IMPORT_TEMPLATE from '@salesforce/resourceUrl/LeadsImportTemplate';
import convertFile from '@salesforce/apex/LeadsImportController.convertFile';
import insertLeads from '@salesforce/apex/LeadsImportController.insertLeads';

export default class LeadsImport extends LightningElement {

    leadsImportTemplate = LEADS_IMPORT_TEMPLATE;
    isLoading = false;
    showModal = false;
    uploadRealizado = false;
    uploadedFileName = '';
    message;

    leadsData = [];
    leadsView = [];

    get acceptedFormats() {
        return ['.csv'];
    }

    handleShowModal() {
        this.showModal = true;
    }

    handleCloseModal() {
        this.uploadRealizado = false;
        this.uploadedFileName = '';
        this.leadsData = [];
        this.leadsView = [];
        this.isLoading = false;
        this.showModal = false;
    }

    handleNewUpload() {
        this.uploadRealizado = false;
        this.uploadedFileName = '';
        this.leadsData = [];
        this.leadsView = [];
        this.isLoading = false;
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFile = event.detail.files;
        console.log(JSON.stringify(uploadedFile));
        this.isLoading = true;
        this.uploadedFileName = uploadedFile[0].name;
        this.convertFile(uploadedFile[0].documentId, uploadedFile[0].contentVersionId);
        
    }

    convertFile(documentId, contentVersionId) {  
        convertFile({
            documentId,
            contentVersionId
        })
        .then(result => {
            console.log(result);
            this.leadsData = result;
            this.leadsView = this.leadsData.slice(0, 9);
            this.uploadRealizado = true;
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            console.log('error: ', error);
			if(error.body && error.body.message){
                this.message = error.body.message === '' ? 'Ocorreu um erro interno ao realizar upload do arquivo.' : error.body.message;
            } else {
                this.message = 'Ocorreu um erro interno ao realizar upload do arquivo.';
            }
			this.showToast('Erro', this.message, 'error');
        });
    }

    insertLeads() {
        this.isLoading = true;

        insertLeads({
            leads: this.leadsData
        })
        .then(result => {
            this.showToast('Sucesso', result, 'success');
            this.handleCloseModal();
        })
        .catch(error => {
            this.isLoading = false;
            console.log('error: ', error);
			if(error.body && error.body.message){
                this.message = error.body.message === '' ? 'Ocorreu um erro interno a inserção dos Leads na base.' : error.body.message;
            } else {
                this.message = 'Ocorreu um erro interno a inserção dos Leads na base.';
            }

            if(this.message.includes('DUPLICATES_DETECTED')) {
                this.showToast('Aviso', 'Foram encontradas informações duplicadas. Evite subir Leads duplicados.', 'warning');
            } else {
                this.showToast('Erro', this.message, 'error');
            }
        });
    }

    showToast(title, message, variant) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(event);
	}

    connectedCallback() {
        console.log(this.leadsImportTemplate);
    }

    columns = [
        { label: 'Tratamento', fieldName: 'Salutation', hideDefaultActions: true },
        { label: 'Primeiro nome', fieldName: 'FirstName', hideDefaultActions: true },
        { label: 'Sobrenome', fieldName: 'LastName', hideDefaultActions: true },        
        { label: 'Telefone', fieldName: 'Phone', type: 'phone', hideDefaultActions: true },
        { label: 'Email', fieldName: 'Email', type: 'email', hideDefaultActions: true },
        { label: 'Origem do Lead', fieldName: 'LeadSource', hideDefaultActions: true },
        { label: 'Outra Origem do Lead', fieldName: 'PRU_otherLeadOrigin__c', hideDefaultActions: true }
    ];
}