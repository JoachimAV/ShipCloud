/// <summary>
/// Page BC2SC_Transport Lines (ID 61004).
/// </summary>
page 61004 "BC2SC_Transport Lines"
{
    Caption = 'BC2SC_Transport Lines';
    PageType = ListPart;
    SourceTable = "BC2SC_Transport Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.TestField("Parcel No.", '');
                        Rec.Validate("Qty. to pack", Rec.Quantity);
                    end;
                }
                field("Weight per Unit"; Rec."Weight per Unit")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Total Weight"; Rec."Total Weight")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("Qty. to pack"; Rec."Qty. to pack")
                {
                    ApplicationArea = All;
                }
                field("Parcel No."; Rec."Parcel No.")
                {
                    ApplicationArea = All;
                }
                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SplitLine)
            {
                ApplicationArea = All;
                ToolTip = 'Split line';
                Image = Splitlines;
                trigger OnAction()
                begin
                    //Todo: Zeile splitten
                    message('Fehlt noch');
                end;
            }
        }
    }
}
