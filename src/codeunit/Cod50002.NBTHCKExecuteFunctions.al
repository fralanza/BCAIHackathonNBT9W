codeunit 50002 "NBT HCK Execute Functions"
{
    TableNo = "NBT HCK Log";


    trigger OnRun()
    begin
        case Rec.Type of
            rec.type::CreateQuote:
                rec.SetOutput(CreateQuote(rec));
            rec.type::ItemPrice:
                Rec.SetOutput(GetItemPrice(rec));
            rec.type::Answer:
                Send(rec);
        end;
        Rec.Modify();
    end;

    procedure CreateQuote(var NBTHCKLog: Record "NBT HCK Log"): Text
    var
        JsonObjectQuote: JsonObject;
        ResponseValue: JsonToken;
        ResponseValueLines: JsonToken;
        Responseitem: JsonToken;
        Responsequantity: JsonToken;
        CustomerNo: Code[20];
        JsonArrayItem: JsonArray;
        i: Integer;
        ItemList: List of [text];
        QuantityList: List of [Decimal];

        //------------------------------------

        SalesHeader: Record "Sales Header";
        Salesline: Record "Sales Line";
        LastLineNo: Integer;
        ItemNo: Text;
        Quantity: Decimal;
        jt: JsonToken;
        ja: JsonArray;
        outstream: OutStream;
        instream: InStream;
        RecRef: RecordRef;
        fldref: FieldRef;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        base64text: Text;
        //------------------------------------

        SalesQuoteCreatedMessage: Label 'Sales quote %1 was created for the customer %2';
    begin

        if not jt.ReadFrom(NBTHCKLog.GetInput()) then
            Error(StrSubstNo(InputBlobError, NBTHCKLog.TableCaption, NBTHCKLog.PK));

        if jt.IsArray then begin
            ja := jt.AsArray();
            ja.get(1, jt);
            JsonObjectQuote := jt.AsObject();
        end else
            if jt.IsObject then begin
                JsonObjectQuote := jt.AsObject();
            end;


        JsonObjectQuote.Get('bestcustomerno', ResponseValue);
        CustomerNo := ResponseValue.AsValue().AsCode();

        Clear(i);
        Clear(ItemList);
        Clear(QuantityList);
        JsonObjectQuote.Get('lines', ResponseValueLines);
        JsonArrayItem := ResponseValueLines.AsArray();
        for i := 0 to (JsonArrayItem.Count - 1) do begin
            JsonArrayItem.Get(i, ResponseValue);
            if ResponseValue.AsObject().Get('bestitemno', Responseitem) AND ResponseValue.AsObject().Get('quantity', Responsequantity) then begin
                ItemList.Add(Responseitem.AsValue().AsText());
                Clear(Quantity);
                Evaluate(Quantity, Responsequantity.AsValue().AsText());
                QuantityList.Add(Quantity);
            end;
        end;

        SalesHeader.Reset();
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Quote;
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Insert(true);

        Clear(i);
        Clear(LastLineNo);
        for i := 1 to ItemList.Count do begin
            Salesline.Reset();
            Salesline.Init();
            Salesline."Document Type" := SalesHeader."Document Type";
            Salesline."Document No." := SalesHeader."No.";
            LastLineNo += 10000;
            Salesline."Line No." := LastLineNo;
            Salesline.Insert(true);
            Salesline.Type := Salesline.Type::Item;
            Clear(ItemNo);
            Clear(Quantity);
            ItemList.Get(i, ItemNo);
            QuantityList.Get(i, Quantity);
            Salesline.Validate("No.", ItemNo);
            Salesline.Validate(Quantity, Quantity);
            Salesline.Modify();
        end;

        NBTHCKLog.Status := 'Processed';
        NBTHCKLog.Processed := CurrentDateTime;

        RecRef := SalesHeader.RecordId.GetRecord();
        fldref := RecRef.Field(3);
        fldref.SetRange(SalesHeader."No.");
        ;
        NBTHCKLog."record id" := SalesHeader.RecordId;

        NBTHCKLog.Attach.CreateOutStream(outstream);
        report.SaveAs(report::"Standard Sales - Quote", '', ReportFormat::Pdf, outstream, RecRef);



        NBTHCKLog.Modify();

        exit(StrSubstNo(SalesQuoteCreatedMessage, SalesHeader."No.", SalesHeader."Sell-to Customer Name"));
    end;

    procedure GetItemPrice(var NBTHCKLog: Record "NBT HCK Log"): Text
    var
        JsonObjectItemPrice: JsonObject;
        ResponseValue: JsonToken;
        CustomerNo: Code[20];
        ItemNo: Code[20];
        Customer: Record Customer;
        Item: Record Item;
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesline: Record "Sales Line" temporary;

        //---------------------------------------------

        NoUnitPriceMessage: Label 'No price is available for item %1 and customer %2';
        FindUnitPriceMessage: Label 'the amount for item %1 and customer %2 is: %3';
    begin

        if not JsonObjectItemPrice.ReadFrom(NBTHCKLog.GetInput()) then
            Error(StrSubstNo(InputBlobError, NBTHCKLog.TableCaption, NBTHCKLog.PK));

        JsonObjectItemPrice.Get('customerno', ResponseValue);
        CustomerNo := ResponseValue.AsValue().AsCode();
        JsonObjectItemPrice.Get('itemno', ResponseValue);
        ItemNo := ResponseValue.AsValue().AsCode();

        TempSalesHeader.Reset();
        TempSalesHeader.Init();
        TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Quote;
        TempSalesHeader."No." := 'TempGetItemPrice';
        TempSalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        TempSalesHeader.Insert(true);

        TempSalesline.reset;
        TempSalesline.init;
        TempSalesline."Document Type" := TempSalesHeader."Document Type";
        TempSalesline."Document No." := TempSalesHeader."No.";
        TempSalesline."Line No." := 10000;
        TempSalesline.Insert(true);
        TempSalesline.Validate(Type, TempSalesline.Type::Item);
        TempSalesline.Validate("No.", ItemNo);

        if TempSalesline."Unit Price" = 0 then begin
            NBTHCKLog.Status := 'Not Found';
            NBTHCKLog.Processed := CurrentDateTime;
            NBTHCKLog.Modify();
            exit(StrSubstNo(NoUnitPriceMessage, ItemNo, CustomerNo));
        end;

        NBTHCKLog.Status := 'Processed';
        NBTHCKLog.Processed := CurrentDateTime;
        NBTHCKLog.Modify();
        exit(StrSubstNo(FindUnitPriceMessage, ItemNo, CustomerNo, TempSalesline."Unit Price"));
    end;



    procedure Send(var rec: record "NBT HCK Log")
    var
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        content: HttpContent;
        jo: JsonObject;
        json: Text;
        reponseText: Text;
        setup: Record "NBT HCK Setup";
        headers: HttpHeaders;
        instream: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        base64text: Text;
    begin
        /*
         customer.get(rec.GetInput());
         customer.CalcFields(Balance);
         rec.SetOutput(customer.Name + ' ha un saldo di ' + FORMAT(customer.Balance));
        */
        setup.get;
        request.SetRequestUri(setup."Callback Url");
        request.Method := 'POST';

        Rec.CalcFields(Attach);
        rec.Attach.CreateInStream(instream);
        base64text := Base64Convert.ToBase64(instream);

        jo.Add('phoneno', rec.PhoneNo);
        jo.Add('email', rec.EMail);
        jo.Add('response', rec.GetInput());
        jo.Add('base64text', base64text);
        jo.WriteTo(json);
        content.WriteFrom(json);
        content.GetHeaders(headers);
        headers.Clear();


        headers.Add('Content-Type', 'application/json');

        request.Content := content;
        client.Send(request, response);
        if response.IsSuccessStatusCode then begin
            rec.Processed := CurrentDateTime;
            rec.Status := 'Processed';
            response.Content.ReadAs(reponseText);
            rec.SetOutput(reponseText);
            rec.Modify();
        end else begin
            response.Content.ReadAs(reponseText);
            ERROR(reponseText);

        end;

    end;

    procedure CalculateCustomer(var rec: record "NBT HCK Log")
    var
        customer: Record customer;
    begin
        /*
         customer.get(rec.GetInput());
         customer.CalcFields(Balance);
         rec.SetOutput(customer.Name + ' ha un saldo di ' + FORMAT(customer.Balance));
 */
        rec.Processed := CurrentDateTime;
        rec.Status := 'Processed';
        rec.Modify();
    end;





    var
        InputBlobError: Label 'Error on input blob of %1 %2';
}