codeunit 50000 "NBT HCK Hackathon"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        log: Record "NBT HCK Log";
        log2: Record "NBT HCK Log";
        openai: Codeunit "NBT HCK OpenAI";
        rid: RecordId;
        recref: RecordRef;
        customer: Record customer;
        jo: JsonObject;
        jo2: JsonObject;
        jt: JsonToken;
        emptyjo: JsonObject;
        ja: JsonArray;
        json: Text;
        item: Record item;
        ExecuteFunctions: Codeunit "NBT HCK Execute Functions";
        OutputText: Text;
        instream: InStream;
        outstream: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
        base64text: Text;
    begin
        Evaluate(rid, rec."Parameter String");
        recref.get(rid);
        recref.SetTable(log);

        if log.Type = log.Type::CreateQuote then begin
            if not ExecuteFunctions.run(log) then begin
                log.Processed := CurrentDateTime;
                log.Status := 'Error';
                log.SetOutput(GetLastErrorText());
                log.Modify(TRUE);
                ClearLastError();
            end else begin
                log2.init;
                log2.pk := 0;
                log2.PhoneNo := log.PhoneNo;
                log2.EMail := log.EMail;
                log2.SetInput(log.GetOutput());
                log2.Queued := CurrentDateTime;
                log2.Type := log2.Type::Answer;
                log2."SOURCE PK" := log.PK;
                log2."SOURCE CONTEXT" := log."SOURCE CONTEXT";
                log.CalcFields(Attach);
                log.Attach.CreateInStream(instream);

                log2.Attach.CreateOutStream(outstream);
                CopyStream(outstream, instream);
                log2.Insert(true);
            end;
            exit;
        end;

        if log.Type = log.Type::ItemPrice then begin

            if not ExecuteFunctions.run(log) then begin
                log.Processed := CurrentDateTime;
                log.Status := 'Error';
                log.SetOutput(GetLastErrorText());
                log.Modify(TRUE);
                ClearLastError();
            end;
            exit;
        end;

        if log.Type = log.Type::Answer then begin
            if not ExecuteFunctions.run(log) then begin
                log.Processed := CurrentDateTime;
                log.Status := 'Error';
                log.SetOutput(GetLastErrorText());
                log.Modify(TRUE);
                ClearLastError();

            end;
            exit;
        end;




        if not openai.run(log) then begin
            log.Processed := CurrentDateTime;
            log.Status := 'Error';
            log.SetOutput(GetLastErrorText());
            log.Modify(TRUE);
            ClearLastError();
        end else begin
            case log.Type of
                log.Type::Context:
                    begin
                        OutputText := log.GetOutput();
                        OutputText := OutputText.Replace('"', '');
                        case OutputText of
                            'RequestSale':
                                begin
                                    log2.init;
                                    log2.pk := 0;
                                    log2.PhoneNo := log.PhoneNo;
                                    log2.EMail := log.EMail;
                                    log2.SetInput(log.GetInput());
                                    log2.Queued := CurrentDateTime;
                                    log2.Type := log2.Type::ParseQuote;
                                    log2."SOURCE PK" := log.PK;
                                    log2."SOURCE CONTEXT" := log.GetOutput();
                                    log2.Insert(true);
                                end;
                            'RequestPurchase':
                                begin
                                    log2.init;
                                    log2.pk := 0;
                                    log2.PhoneNo := log.PhoneNo;
                                    log2.EMail := log.EMail;
                                    log2.SetInput(log.GetInput());
                                    log2.Queued := CurrentDateTime;
                                    log2.Type := log2.Type::ParseQuote;
                                    log2."SOURCE PK" := log.PK;
                                    log2."SOURCE CONTEXT" := log.GetOutput();
                                    log2.Insert(true);
                                end;

                            'StatusCustomer':
                                begin
                                    log2.init;
                                    log2.pk := 0;
                                    log2.PhoneNo := log.PhoneNo;
                                    log2.EMail := log.EMail;
                                    jo.Add('text', log.GetInput());
                                    if customer.FindSet() then
                                        repeat
                                            jo2 := emptyjo.Clone().AsObject();
                                            jo2.Add('no', customer."No.");
                                            jo2.Add('name', customer.Name);
                                            ja.Add(jo2.AsToken());
                                        until customer.next = 0;
                                    jo.Add('customers', ja);
                                    jo.WriteTo(json);

                                    log2.SetInput(json);
                                    log2.Queued := CurrentDateTime;
                                    log2.Type := log2.Type::ParseCustomer;
                                    log2."SOURCE PK" := log.PK;
                                    log2."SOURCE CONTEXT" := log.GetOutput();
                                    log2.Insert(true);
                                end;
                            'ItemPrice':
                                begin
                                    log2.init;
                                    log2.pk := 0;
                                    log2.PhoneNo := log.PhoneNo;
                                    log2.EMail := log.EMail;
                                    log2.SetInput(log.GetInput());
                                    log2.Queued := CurrentDateTime;
                                    log2.Type := log2.Type::ParcePrice;
                                    log2."SOURCE PK" := log.PK;
                                    log2."SOURCE CONTEXT" := log.GetOutput();
                                    log2.Insert(true);
                                end;
                        end;
                    end;
                log.Type::ParseQuote, log.Type::ParcePrice:
                    begin
                        log2.init;
                        log2.pk := 0;
                        log2.PhoneNo := log.PhoneNo;
                        log2.EMail := log.EMail;
                        jo.ReadFrom(log.GetOutput());
                        if customer.FindSet() then
                            repeat
                                jo2 := emptyjo.Clone().AsObject();
                                jo2.Add('no', customer."No.");
                                jo2.Add('name', customer.Name);
                                ja.Add(jo2.AsToken());
                            until customer.next = 0;
                        jo.Add('customers', ja);
                        jo.WriteTo(json);
                        log2.SetInput(json);
                        log2.Queued := CurrentDateTime;
                        log2.Type := log2.Type::Customer;
                        log2."SOURCE PK" := log.PK;
                        log2."SOURCE CONTEXT" := log."SOURCE CONTEXT";
                        log2.Insert(true);
                    end;
                log.Type::Customer:
                    begin
                        log2.init;
                        log2.pk := 0;
                        log2.PhoneNo := log.PhoneNo;
                        log2.EMail := log.EMail;
                        jo.ReadFrom(log.GetOutput());

                        if item.FindSet() then
                            repeat
                                jo2 := emptyjo.Clone().AsObject();
                                jo2.Add('no', item."No.");
                                jo2.Add('description', item.description);
                                ja.Add(jo2.AsToken());
                            until item.next = 0;
                        jo.Add('items', ja);
                        if jo.Contains('customers') then
                            jo.Remove('customers');
                        jo.WriteTo(json);
                        log2.SetInput(json);
                        log2.Queued := CurrentDateTime;
                        case log."SOURCE CONTEXT" of
                            'StatusCustomer':
                                log2.Type := log2.Type::ParseCustomer;
                            'RequestPurchase', 'RequestSale', 'ItemPrice':
                                log2.Type := log2.Type::Item;
                        end;
                        log2."SOURCE PK" := log.PK;
                        log2."SOURCE CONTEXT" := log."SOURCE CONTEXT";
                        log2.Insert(true);
                    end;
                log.Type::Item:
                    begin
                        log2.init;
                        log2.pk := 0;
                        log2.PhoneNo := log.PhoneNo;
                        log2.EMail := log.EMail;
                        jt.ReadFrom(log.GetOutput());
                        if jt.IsArray then begin
                            ja := jt.AsArray();
                            ja.get(1, jt);
                            jo := jt.AsObject();
                        end else begin
                            jo := jt.AsObject();
                        end;


                        if jo.Contains('items') then
                            jo.Remove('items');
                        jo.WriteTo(json);
                        log2.SetInput(json);
                        log2.Queued := CurrentDateTime;
                        case log."SOURCE CONTEXT" of
                            'ItemPrice':
                                log2.Type := log2.Type::ItemPrice;
                            'RequestPurchase', 'RequestSale':
                                log2.Type := log2.Type::CreateQuote;
                        end;
                        log2."SOURCE PK" := log.PK;
                        log2."SOURCE CONTEXT" := log."SOURCE CONTEXT";
                        log2.Insert(true);
                    end;
                log.Type::ParseCustomer:
                    begin
                        log2.init;
                        log2.pk := 0;
                        log2.PhoneNo := log.PhoneNo;
                        log2.EMail := log.EMail;
                        log2.SetInput(log.GetOutput());
                        log2.Queued := CurrentDateTime;
                        log2.Type := log2.Type::GetCustomerData;
                        log2."SOURCE PK" := log.PK;
                        log2."SOURCE CONTEXT" := log."SOURCE CONTEXT";
                        log2.Insert(true);
                    end;

                log.type::GetCustomerData:
                    begin
                        log2.init;
                        log2.pk := 0;
                        log2.PhoneNo := log.PhoneNo;
                        log2.EMail := log.EMail;
                        log2.SetInput(log.GetOutput());
                        log2.Queued := CurrentDateTime;
                        log2.Type := log2.Type::Answer;
                        log2."SOURCE PK" := log.PK;
                        log2."SOURCE CONTEXT" := log."SOURCE CONTEXT";
                        log2.Insert(true);
                    end;
            end;
        end;
    end;


    procedure Process(var log: Record "NBT HCK Log")
    var
        jqd: Codeunit "Job Queue Dispatcher";
        jqe: Record "Job Queue Entry";
    begin
        jqe.init;
        jqe.ID := CreateGuid();
        jqe."Object Type to Run" := jqe."Object Type to Run"::Codeunit;
        jqe."Object ID to Run" := Codeunit::"NBT HCK Hackathon";
        jqe."Parameter String" := FORMAT(log.RecordId);
        jqe.Insert();

        jqd.Run(jqe);


    end;

    [EventSubscriber(ObjectType::Table, Database::"NBT HCK Log", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertLogEvent(var Rec: Record "NBT HCK Log"; RunTrigger: Boolean)
    begin
        Process(rec);
    end;
}
