page 50002 "NBT HCK Log"
{
    ApplicationArea = All;
    Caption = 'NBT HCK Log';
    PageType = ListPart;
    SourceTable = "NBT HCK Log";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(PK; Rec.PK)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PK field.';
                }
                field("SOURCE CONTEXT"; Rec."SOURCE CONTEXT")
                {
                    ApplicationArea = All;
                }
                field("SOURCE PK"; Rec."SOURCE PK")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SOURCE PK field.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field(PhoneNo; Rec.PhoneNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PhoneNo field.';
                }
                field(EMail; Rec.EMail)
                {
                    ApplicationArea = All;
                }
                field("Salesperson Name"; Rec."Salesperson Name")
                {
                    ApplicationArea = All;
                }
                field(Queued; Rec.Queued)
                {
                    ApplicationArea = All;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("record id"; FORMAT(Rec."record id"))
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        recref: RecordRef;
                        sh: Record "Sales Header";
                        p: page "Sales Quote";
                    begin
                        recref.get(rec."record id");
                        recref.SetTable(sh);
                        sh.SetRange("No.", sh."No.");
                        p.SetTableView(sh);
                        p.SetRecord(sh);
                        p.RunModal();
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Process)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                    rec.Process();
                end;
            }
            action(Download)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    is: InStream;
                    filename: Text;
                begin
                    rec.CalcFields(Attach);
                    rec.Attach.CreateInStream(is);
                    filename := FORMAT(rec.PK) + '.pdf';
                    DownloadFromStream(is, 'download', '', '', filename);
                end;
            }
            action(GetInputMessage)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                    MESSAGE(rec.GetInput());
                end;
            }
            action(GetOutputMessage)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                    MESSAGE(rec.GetOutput());
                end;
            }
        }
    }
}
