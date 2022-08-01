/// <summary>
/// PageExtension Warehouse Pick (ID 61001) extends Record Warehouse Pick.
/// </summary>
pageextension 61001 "Warehouse Pick" extends "Warehouse Pick"
{
    layout
    {

    }
    actions
    {
        addafter("Delete Qty. to Handle")
        {
            Action(CreateTransport)
            {
                Image = NewShipment;
                ApplicationArea = All;
                Caption = 'Create Transport';
                trigger OnAction()
                var
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                    TransportHeader: Record "BC2SC_Transport Header";
                    TranspDoc: Code[20];
                    ConfMsg001: Label 'Create Transport for this Warehouse Pick Document?';
                    ConfMsg002: Label 'Transport %1 created. Open Document?';
                    ConfMsg003: Label 'Transport %1 for this Document exists. Create a new Transport Document?';
                begin
                    if Confirm(ConfMsg001) then begin
                        TransportHeader.setrange("Created from Document Type", TransportHeader."Created from Document Type"::"Whse.Act.Header");
                        TransportHeader.setrange("Created from Document No.", Rec."No.");
                        if TransportHeader.FindFirst() then
                            if not Confirm(ConfMsg003, true, TransportHeader."No.") then
                                exit;

                        TransportHeader.reset;

                        TranspDoc := ShipCloudMgt.CreateTranspFromWhseActHeader(Rec);
                        if Confirm(ConfMsg002, true, TranspDoc) then begin
                            TransportHeader.get(TranspDoc);
                            page.run(page::"BC2SC_Transport Card", TransportHeader);
                        end;
                    end;
                end;
            }
        }
    }
}
