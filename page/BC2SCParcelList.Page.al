/// <summary>
/// Page BC2SC_Parcel List (ID 61006).
/// </summary>
page 61006 "BC2SC_Parcel List"
{
    ApplicationArea = All;
    Caption = 'BC2SC_Parcel List';
    PageType = List;
    SourceTable = BC2SC_Parcel;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = False;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = False;
                }
                field("Transport No."; Rec."Transport No.")
                {
                    ApplicationArea = All;
                    Editable = False;
                }
                field(Height; Rec.Height)
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }
                field(Length; Rec.Length)
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }
                field(Width; Rec.Width)
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ShowMandatory = True;
                }

                field("Packaging Code"; Rec."Packaging Code")
                {
                    ApplicationArea = All;
                }
                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = All;
                }
                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
