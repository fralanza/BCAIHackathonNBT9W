using System.AI;
using System.Environment;


table 50000 "NBT HCK Setup"
{
    Caption = 'Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; pk; Code[1])
        {
            Caption = 'pk';
        }
        field(10; "AOAI Model Type"; Enum "AOAI Model Type")
        {
            Caption = 'OpenAI Model Type';
        }

        field(20; "AOAI Endpoint"; Text[2048])
        {
            Caption = 'OpenAI Endpoint';
        }
        field(30; "AOAI Deployment"; Text[2048])
        {
            Caption = 'OpenAI Deployment';
        }
        field(40; "AOAI ApiKEY"; Text[2048])
        {
            Caption = 'OpenAI ApiKEY';
            ExtendedDatatype = Masked;
        }
        field(50; "AOAI MaxToken"; Integer)
        {
            Caption = 'OpenAI MaxToken';

        }
        field(60; "AOAI Temperature"; Decimal)
        {
            Caption = 'OpenAI Temperature';
            MinValue = 0;
            MaxValue = 2;
            DecimalPlaces = 1;

        }


        field(110; "AOAI contextprompt"; Text[2048])
        {
            Caption = 'Context Prompt';

        }

        field(120; "AOAI parseitempriceprompt"; Text[2048])
        {
            Caption = 'Parse Item Price Prompt';

        }

        field(130; "AOAI getitemprompt"; Text[2048])
        {
            Caption = 'Get Item No. Prompt';

        }

        field(140; "AOAI getcustomernoprompt"; Text[2048])
        {
            Caption = 'Gest Customer No. Prompt';

        }
        field(150; "AOAI parseQuoteprompt"; Text[2048])
        {
            Caption = 'Get Parse Quote Prompt';

        }
        field(160; "AOAI parsecustomerprompt"; Text[2048])
        {
            Caption = 'Get Parse Customer Prompt';

        }
        field(170; "Callback Url"; Text[2048])
        {

        }

    }
    keys
    {
        key(PK; pk)
        {
            Clustered = true;
        }
    }

    procedure GetAPIKEY(): SecretText
    var
        myInt: Integer;
    begin
        exit(rec."AOAI ApiKEY");
    end;
}
