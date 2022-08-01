/// <summary>
/// Page BC2SC_Transport List (ID 61002).
/// </summary>
page 61002 "BC2SC_Transport List"
{
    ApplicationArea = All;
    Caption = 'BC2SC_Transport List';
    PageType = List;
    SourceTable = "BC2SC_Transport Header";
    UsageCategory = Lists;
    CardPageId = 61003;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Ship-from Name"; Rec."Ship-from Name")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Ship-from Name 2"; Rec."Ship-from Name 2")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Ship-from Address"; Rec."Ship-from Address")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Ship-from Address 2"; Rec."Ship-from Address 2")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Ship-from Post Code"; Rec."Ship-from Post Code")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Ship-from Country/Region Code"; Rec."Ship-from Country/Region Code")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Created from Document Type"; Rec."Created from Document Type")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Created from Document No."; Rec."Created from Document No.")
                {
                    ApplicationArea = All;
                }
                field("Source Document Type"; Rec."Source Document Type")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
