page 50003 "NBT HCK SalesPerson"
{
    ApplicationArea = All;
    Caption = 'NBT HCK SalesPerson';
    PageType = List;
    Editable = false;
    SourceTable = "Salesperson/Purchaser";
    SourceTableView = where("NBT HCK Enable Whatsapp" = const(true));
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies a code for the salesperson or purchaser.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the salesperson or purchaser.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the salesperson''s telephone number.';
                }
                field("E-Mail"; Rec."E-Mail")
                {

                }

            }
        }
    }
}
