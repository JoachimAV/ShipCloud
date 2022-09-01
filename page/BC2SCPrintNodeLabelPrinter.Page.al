page 61008 "BC2SC_PrintNode Label Printer"
{
    ApplicationArea = All;
    Caption = 'PrintNode Label Printer';
    PageType = List;
    SourceTable = "BC2SC_PrintNode Label Printer";
    UsageCategory = Administration;

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
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Printer ID"; Rec."Printer ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
