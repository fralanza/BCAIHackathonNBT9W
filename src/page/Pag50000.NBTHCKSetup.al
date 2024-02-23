page 50000 "NBT HCK Setup"
{
    ApplicationArea = All;
    Caption = 'NBT HCK';
    PageType = Card;
    SourceTable = "NBT HCK Setup";

    layout
    {
        area(content)
        {
            group("OPENAI Setup")
            {
                Caption = 'OPENAI Setup';

                field("AOAI ApiKEY"; Rec."AOAI ApiKEY")
                {
                    ToolTip = 'Specifies the value of the OpenAI ApiKEY field.';

                }
                field("AOAI Deployment"; Rec."AOAI Deployment")
                {
                    ToolTip = 'Specifies the value of the OpenAI Deployment field.';
                }
                field("AOAI Endpoint"; Rec."AOAI Endpoint")
                {
                    ToolTip = 'Specifies the value of the OpenAI Endpoint field.';
                }
                field("AOAI Model Type"; Rec."AOAI Model Type")
                {
                    ToolTip = 'Specifies the value of the OpenAI Model Type field.';
                }
                field("AOAI Temperature"; Rec."AOAI Temperature")
                {
                    ToolTip = 'Specifies the value of the Temperature field.';
                    MultiLine = true;
                }
                field("AOAI MaxToken"; Rec."AOAI MaxToken")
                {
                    ToolTip = 'Specifies the value of the Temperature field.';
                    MultiLine = true;
                }
                field("Callback Url"; Rec."Callback Url")
                {
                    MultiLine = true;
                }
            }
            group(Prompt)
            {
                Caption = 'Prompt';
                field("AOAI contextprompt"; Rec."AOAI contextprompt")
                {
                    ToolTip = 'Specifies the value of the Context Prompt field.';
                    MultiLine = true;
                }
                field("AOAI getcustomernoprompt"; Rec."AOAI getcustomernoprompt")
                {
                    ToolTip = 'Specifies the value of the Gest Customer No. Prompt field.';
                    MultiLine = true;
                }
                field("AOAI getitemprompt"; Rec."AOAI getitemprompt")
                {
                    ToolTip = 'Specifies the value of the Get Item No. Prompt field.';
                    MultiLine = true;
                }
                field("AOAI parseitempriceprompt"; Rec."AOAI parseitempriceprompt")
                {
                    ToolTip = 'Specifies the value of the Parse Item Price Prompt field.';
                    MultiLine = true;
                }
                field("AOAI parseQuoteprompt"; Rec."AOAI parseQuoteprompt")
                {
                    ToolTip = 'Specifies the value of the Parse Quote Prompt field.';
                    MultiLine = true;
                }
                field("AOAI parsecustomerprompt"; Rec."AOAI parsecustomerprompt")
                {
                    ToolTip = 'Specifies the value of the Parse Customer Prompt field.';
                    MultiLine = true;
                }
            }
        }
    }

}
