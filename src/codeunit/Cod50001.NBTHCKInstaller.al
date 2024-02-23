

namespace CopilotToolkitDemo.ItemSubstitution;

using System.AI;
using System.Text;
using System.Environment;

codeunit 50001 "NBT HCK Installer"
{
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var

        cc: enum "Copilot Capability";
    begin

        AddCapability("Copilot Capability"::Chat);
        AddCapability("Copilot Capability"::Context);

        AddCapability("Copilot Capability"::Customer);

        AddCapability("Copilot Capability"::Item);
        AddCapability("Copilot Capability"::ParseCustomer);
        AddCapability("Copilot Capability"::ParseQuote);
        AddCapability("Copilot Capability"::ParcePrice);
        AddCapability("Copilot Capability"::CreateQuote);
        AddCapability("Copilot Capability"::ItemPrice);
    end;

    local procedure AddCapability(input: enum "Copilot Capability")
    var
        CopilotCapability: Codeunit "Copilot Capability";
    begin
        if not CopilotCapability.IsCapabilityRegistered(input) then
            CopilotCapability.RegisterCapability(input, Enum::"Copilot Availability"::Preview, 'x3n0n');
    end;
}