table 50001 "NBT HCK Log"
{
    Caption = 'NBT HCK Log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; PK; Integer)
        {
            Caption = 'PK';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }

        field(2; PhoneNo; Text[50])
        {
            Caption = 'Phone no.';
            DataClassification = CustomerContent;
        }
        field(3; Queued; DateTime)
        {
            Caption = 'Queued.';
            DataClassification = CustomerContent;
        }
        field(4; Processed; DateTime)
        {
            Caption = 'Processed';
            DataClassification = CustomerContent;
        }
        field(5; Type; enum "Copilot Capability")
        {
            Caption = 'Type';
        }
        field(6; EMail; Text[100])
        {
            Caption = 'EMail';
            DataClassification = CustomerContent;
        }
        field(100; Input; Blob)
        {
            Caption = 'Input';
            DataClassification = CustomerContent;
        }
        field(110; Output; Blob)
        {
            Caption = 'Input';
            DataClassification = CustomerContent;
        }
        field(120; Status; Text[100])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(130; "SOURCE PK"; Integer)
        {
            Caption = 'SOURCE PK';
            DataClassification = CustomerContent;

        }
        field(140; "SOURCE CONTEXT"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(150; "Attach"; Blob)
        {
            Caption = 'Attach';
            DataClassification = CustomerContent;
        }
        field(299; "Salesperson Name"; Text[100])
        {
            Caption = 'Salesperson Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Salesperson/Purchaser".Name where("Phone No." = field(PhoneNo)));
        }
        field(230; "record id"; RecordId)
        {
            Caption = 'Record id';
        }
    }
    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }

    procedure GetOutput() output: Text
    var
        is: InStream;
    begin
        CalcFields(Rec."Output");

        if (Rec."Output".HasValue) then begin
            Rec."Output".CreateInStream(is, TextEncoding::UTF8);
            is.Read(output);
        end;
    end;


    procedure SetOutput(input: Text)
    var
        os: OutStream;
    begin
        Output.CreateOutStream(os, TextEncoding::UTF8);
        os.Write(input);
    end;


    procedure GetInput() output: Text
    var
        is: InStream;
    begin
        CalcFields(Rec."Input");

        if (Rec."Input".HasValue) then begin
            Rec."Input".CreateInStream(is, TextEncoding::UTF8);
            is.Read(output);
        end;
    end;


    procedure SetInput(input: Text)
    var
        os: OutStream;
    begin
        Rec.Input.CreateOutStream(os, TextEncoding::UTF8);
        os.Write(input);
    end;

    procedure Process()
    var
        h: Codeunit "NBT HCK Hackathon";
    begin
        h.Process(rec);
    end;
}
