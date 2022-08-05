/// <summary>
/// PageExtension Sales Hist. Sell-to FactBox (ID 61006) extends Record Sales Hist. Sell-to FactBox.
/// </summary>
pageextension 61006 "Sales Hist. Sell-to FactBox" extends "Sales Hist. Sell-to FactBox"
{
    layout
    {
        addafter(NoofPstdCreditMemosTile)
        {
            field("BC2SC_Qty. Transports"; Rec."BC2SC_Qty. Transports")
            {
                ApplicationArea = All;
                Visible = True;
                Caption = 'Qty. Transports';
                ToolTip = 'No. of created transports to customer';
                DrillDownPageId = "BC2SC_Transport List";
            }
        }
    }
}
