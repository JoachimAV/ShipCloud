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
                Caption = 'General';
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
                caption = 'No. Series';
                field("Transport No. Series"; Rec."Transport No. Series")
                {
                    ApplicationArea = All;
                }
                field("Parcel No. Series"; Rec."Parcel No. Series")
                {
                    ApplicationArea = All;
                }
            }
            group(Defaults)
            {
                Caption = 'Defaults';
                field("Def. Qty. to Pack with Qty."; Rec."Def. Qty. to Pack with Qty.")
                {
                    ApplicationArea = All;
                }
                field("Def. Transport Item No."; Rec."Def. Transport Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This item is inserted automatically to Transports, when no Items in Documents exists.';
                }
                field("Cr. Transp. w. Reg. Whse. Pick"; Rec."Cr. Transp. w. Reg. Whse. Pick")
                {
                    ApplicationArea = All;
                    ToolTip = 'Creates Transport Documents automatically when Warehouse Pick is registered.\If there is an document created manually, nothing happens';
                }
                field("Cr. Transp. w. Sales.-Post"; Rec."Cr. Transp. w. Sales.-Post")
                {
                    ApplicationArea = All;
                    ToolTip = 'Creates Transport Documents automatically when Sales Order is posted.\If there is an document created manually, nothing happens';
                }
                field("Cr. Transp. w. Serv.-Post"; Rec."Cr. Transp. w. Serv.-Post")
                {
                    ApplicationArea = All;
                    ToolTip = 'Creates Transport Documents automatically when Service Order is posted.\If there is an document created manually, nothing happens';
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
