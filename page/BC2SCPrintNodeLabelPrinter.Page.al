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
                field(Rotate; Rec.Rotate)
                {
                    ApplicationArea = All;
                }
                field(Paper; Rec.Paper)
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
            action(GetPrinterSetup)
            {
                Caption = 'Get Printer Setup';
                ApplicationArea = All;
                trigger OnAction()
                var
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                begin
                    ShipCloudMgt.GetPrinterParameter(Rec);
                end;

            }
        }
    }
}
