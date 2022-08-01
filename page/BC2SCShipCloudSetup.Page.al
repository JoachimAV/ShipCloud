/// <summary>
/// Page BC2SC_ShipCloud Setup (ID 61000).
/// </summary>
page 61000 "BC2SC_ShipCloud Setup"
{
    Caption = 'ShipCloud Setup';
    ApplicationArea = All;
    UsageCategory = Administration;
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
                field(Debug; Rec.Debug)
                {
                    ApplicationArea = All;
                }
            }
            group(NoSeries)
            {
                field("Transport No. Series"; Rec."Transport No. Series")
                {
                    ApplicationArea = All;
                }
                field("Parcel No. Series"; Rec."Parcel No. Series")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.Get() Then begin
            Rec.Init;
            Rec."API Base URL" := 'https://api.shipcloud.io/v1/';
            Rec.Insert(true);

        end;
    end;
}
