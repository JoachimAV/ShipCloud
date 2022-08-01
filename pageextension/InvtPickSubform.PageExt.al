/// <summary>
/// PageExtension Invt. Pick Subform (ID 61002) extends Record Invt. Pick Subform.
/// </summary>
pageextension 61002 "Invt. Pick Subform" extends "Invt. Pick Subform"
{
    layout
    {

    }
    actions
    {
        addafter("Source &Document Line")
        {
            action(BC2SC_ItemTrackingLines)
            {
                ApplicationArea = ItemTracking;
                Caption = 'Item &Tracking Lines';
                Image = ItemTrackingLines;
                ShortCutKey = 'Ctrl+Alt+I';
                ToolTip = 'View or edit serial and lot numbers for the selected item. This action is available only for lines that contain an item.';
                trigger OnAction()
                var
                    SalesLine: Record "Sales Line";
                begin
                    Rec.TestField("Source Type", 37);
                    Salesline.get(Rec."Source Subtype", Rec."Source No.", Rec."Source Line No.");
                    Salesline.OpenItemTrackingLines();
                end;
            }
        }
    }
}
