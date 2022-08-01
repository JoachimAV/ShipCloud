/// <summary>
/// PageExtension Shipping Agents (ID 61000) extends Record Shipping Agents.
/// </summary>
pageextension 61000 "BC2SC_Shipping Agents" extends "Shipping Agents"
{
    layout
    {
        addafter(Name)
        {
            field("BC2SC_Shipcloud Agent Name"; Rec."BC2SC_Shipcloud Agent Name")
            {
                ApplicationArea = All;
            }
        }
    }
}
