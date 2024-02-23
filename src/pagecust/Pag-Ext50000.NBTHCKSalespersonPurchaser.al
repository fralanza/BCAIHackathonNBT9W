pageextension 50000 "NBT HCK Salesperson/Purchaser" extends "Salesperson/Purchaser Card"
{
    layout
    {

        addafter("Phone No.")
        {
            field("NBT HCK Enable Whatsapp"; Rec."NBT HCK Enable Whatsapp")
            {
                ApplicationArea = All;
            }
        }
    }
}
