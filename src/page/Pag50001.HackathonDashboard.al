page 50001 "Hackathon Dashboard"
{
    ApplicationArea = All;
    Caption = 'Hackathon Dashboard';
    PageType = RoleCenter;
    SourceTable = "NBT HCK Log";

    layout
    {
        area(RoleCenter)
        {
            part(Log; "NBT HCK Log")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Setup)
            {
                ApplicationArea = All;
                RunObject = page "NBT HCK Setup";
                RunPageMode = Edit;

            }
        }
    }
}
