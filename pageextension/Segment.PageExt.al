pageextension 61007 "BC2SC_Segment" extends Segment
{
    layout
    {
        addafter("No. of Criteria Actions")
        {
            field("Qty. Transports"; Rec."BC2SC_Qty. Transports")
            {
                ApplicationArea = All;
            }
            field("Shipping Item No."; Rec."BC2SC_Shipping Item No.")
            {
                ApplicationArea = All;
            }
            field("Packaging Code"; Rec."BC2SC_Packaging Code")
            {
                ApplicationArea = All;
            }
            field("Parcel Weight"; Rec."BC2SC_Parcel Weight")
            {
                ApplicationArea = All;
            }
            field("BC2SC_Shipping Agent Code"; Rec."BC2SC_Shipping Agent Code")
            {
                ApplicationArea = All;
            }
            field("BC2SC_Ship. Agent Service Code"; Rec."BC2SC_Ship. Agent Service Code")
            {
                ApplicationArea = All;
            }
        }

    }
    actions
    {
        addafter(ExportContacts)
        {
            action(CreateShipCloudTransports)
            {
                ApplicationArea = All;
                Caption = 'Create ShipCloud Transport';
                Image = SendToMultiple;
                trigger OnAction()
                var
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                begin
                    ShipCloudMgt.CreateTranspFromSegmentHeader(Rec);
                end;
            }
        }
    }
}
