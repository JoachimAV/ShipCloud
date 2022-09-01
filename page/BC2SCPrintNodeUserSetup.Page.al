page 61009 "BC2SC_PrintNode User Setup"
{
    ApplicationArea = All;
    Caption = 'PrintNode User Setup';
    PageType = List;
    SourceTable = "BC2SC_PrintNode User Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    TableRelation = "User Setup"."User ID";
                }
                field("Label Printer"; Rec."Label Printer")
                {
                    ApplicationArea = All;
                }
                field("Label Printer Name"; Rec."Label Printer Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
