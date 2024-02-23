page 50004 NBTHCKLogAPI
{
    APIGroup = 'Hackathon';
    APIPublisher = 'NBT';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'nbthckLogAPI';
    DelayedInsert = true;
    EntityName = 'Log';
    EntitySetName = 'Logs';
    PageType = API;
    SourceTable = "NBT HCK Log";
    ODataKeyFields = PK;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(PK; Rec.PK)
                {
                    Caption = 'PK';
                    Editable = false;
                }
                field(phoneNo; Rec.PhoneNo)
                {
                    Caption = 'Phone no.';
                }
                field(EMail; Rec.EMail)
                {
                    Caption = 'EMail';
                }


                field(input; InputData)
                {
                    Caption = 'Input';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Dispatch)
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    hackthon: Codeunit "NBT HCK Hackathon";
                begin
                    hackthon.Process(rec);
                    ;
                end;
            }
        }
    }
    var
        inputData: text;

    trigger OnInsertRecord(BelowRec: Boolean): Boolean
    var
        os: OutStream;
    begin
        Rec.Type := rec.Type::Context;//alla ricezione devo capire il contesto
        Rec.Status := 'Logged';
        rec.Queued := CurrentDateTime;
        Rec.Input.CreateOutStream(os, TextEncoding::UTF8);
        os.Write(inputData);
    end;
}
