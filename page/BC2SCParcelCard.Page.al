/// <summary>
/// Page BC2SC_Parcel Card (ID 61001).
/// </summary>
page 61001 "BC2SC_Parcel Card"
{
    Caption = 'BC2SC_Parcel Card';
    PageType = Card;
    SourceTable = BC2SC_Parcel;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Packaging Code"; Rec."Packaging Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Height; Rec.Height)
                {
                    ApplicationArea = All;
                }
                field(Length; Rec.Length)
                {
                    ApplicationArea = All;
                }
                field(Width; Rec.Width)
                {
                    ApplicationArea = All;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                }
                field("Max. Weight"; Rec."Max. Weight")
                {
                    ApplicationArea = All;

                }
                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                }
                field("Transport No."; Rec."Transport No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links)
            {
                Applicationarea = All;
            }
        }
    }
}
