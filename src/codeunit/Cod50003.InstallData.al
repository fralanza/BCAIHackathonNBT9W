codeunit 50003 "Install Data"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin

        UpdateSetupHCK();
    end;

    local procedure UpdateSetupHCK();
    var
        HCKSetup: Record "NBT HCK Setup";
    begin
        HCKSetup.Reset();
        if not HCKSetup.Get() then begin
            HCKSetup.Init();
            HCKSetup.pk := '';
            HCKSetup.Insert();
        end;

        HCKSetup."AOAI Model Type" := HCKSetup."AOAI Model Type"::"Chat Completions";
        if HCKSetup."AOAI Endpoint" = '' then
            HCKSetup."AOAI Endpoint" := 'https://bc-ai-hackaton-2024.openai.azure.com/';
        if HCKSetup."AOAI Deployment" = '' then
            HCKSetup."AOAI Deployment" := 'gpt-35-turbo';
        if HCKSetup."AOAI ApiKEY" = '' then
            HCKSetup."AOAI ApiKEY" := 'enter your key here';
        if HCKSetup."AOAI MaxToken" = 0 then
            HCKSetup."AOAI MaxToken" := 2000;
        if HCKSetup."AOAI contextprompt" = '' then
            HCKSetup."AOAI contextprompt" := 'Analyze the following text and define a category from the 4 given below: 1) "RequestPurchase": to be used in case something is requested to be bought 2) "RequestSale" to be used in case something is requested to be sold 3) "InventoryStock": to be used when requested to check the stock of one or more products 4) "StatusCustomer": to be used when customer information is requested In case you cannot associate it with anything respond with the following status "Null" you need to answer me only with the category name 5) "ItemPrice" : to be used when requested to check the sales price of one products for a specific customer';
        if HCKSetup."AOAI getitemprompt" = '' then
            HCKSetup."AOAI getitemprompt" := '[no prose]Loop through the elements of the ''lines'' property in the following JSON, and for each of them, find the best match of the ''no'' property among the elements in the ''items'' array. Add a new property called ''bestitemno'' to each one with the identified ''no'' value. give me only the modified json. Do not add any comments or elements other than the __model_output__ value itself . ';
        if HCKSetup."AOAI getcustomernoprompt" = '' then
            HCKSetup."AOAI getcustomernoprompt" := '[no prose] find the best match of the ''customer'' property among the elements in the ''customers'' array. Add a new property called ''bestcustomerno'' to the json object. give me  only the modified json. Do not add any comments or elements other than the __model_output__ value itself . ';
        if HCKSetup."AOAI parseQuoteprompt" = '' then
            HCKSetup."AOAI parseQuoteprompt" := 'parse the following text and return only a JSON describing it as a document with a property customer with the name of the buyer and an array of elements named lines with a property named itemname with the item and a property quantity.Do not add any comments or elements other than the JSON itself';
        if HCKSetup."AOAI parseitempriceprompt" = '' then
            HCKSetup."AOAI parseitempriceprompt" := '[no prose] parse the following text and return only a JSON describing it as a document with the "customer no." and "Item No."';
        if HCKSetup."AOAI parsecustomerprompt" = '' then
            HCKSetup."AOAI parsecustomerprompt" := '[no prose] Identify the customer from the ''Customers''. return only the value ''Customer No.''';
        HCKSetup.Modify();
    end;
}