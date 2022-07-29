/// <summary>
/// Page BC2SC_ShipCloud Setup (ID 61000).
/// </summary>
page 61000 "BC2SC_ShipCloud Setup"
{
    Caption = 'ShipCloud Setup';
    PageType = Card;
    SourceTable = "BC2SC_ShipCloud Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("API Base URL"; Rec."API Base URL")
                {
                    ApplicationArea = All;
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
