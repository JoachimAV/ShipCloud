/// <summary>
/// Page "BC2SC_Packagings" (ID 61005).
/// </summary>
page 61005 BC2SC_Packagings
{
    ApplicationArea = All;
    Caption = 'Packagings';
    PageType = List;
    SourceTable = BC2SC_Packaging;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
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
                field("Max. Weight"; Rec."Max. Weight")
                {
                    ApplicationArea = All;
                }
                field("Package weight"; Rec."Package weight")
                {

                    ApplicationArea = All;
                }

            }
        }
    }
}
