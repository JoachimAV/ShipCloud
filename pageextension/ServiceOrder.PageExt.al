/// <summary>
/// PageExtension Service Order (ID 61003) extends Record Service Order.
/// </summary>
pageextension 61003 "BC2SC_Service Order" extends "Service Order"
{
    layout
    {

    }
    actions
    {
        addafter("Create Whse Shipment")
        {
            action(BC2SC_CreateTransport)
            {
                Image = NewWarehouseShipment;
                Caption = 'Create Transport';
                ApplicationArea = All;

                trigger OnAction()
                var
                    ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
                    TransportHeader: Record "BC2SC_Transport Header";
                    TranspDoc: Code[20];
                    ConfMsg001: Label 'Create Transport for this Service Order?';
                    ConfMsg002: Label 'Transport %1 created. Open Document?';
                    ConfMsg003: Label 'Transport %1 for this Document exists. Create a new Transport Document?';
                begin
                    if Confirm(ConfMsg001) then begin
                        TransportHeader.setrange("Created from Document Type", TransportHeader."Created from Document Type"::"Whse.Act.Header");
                        TransportHeader.setrange("Created from Document No.", Rec."No.");
                        TransportHeader.setrange("Transport Document Type", TransportHeader."Transport Document Type"::Shipment);
                        if TransportHeader.FindFirst() then
                            if not Confirm(ConfMsg003, true, TransportHeader."No.") then
                                exit;

                        TransportHeader.reset;

                        TranspDoc := ShipCloudMgt.CreateTranspFromServiceOrder(Rec, TransportHeader."Transport Document Type"::Shipment);
                        if Confirm(ConfMsg002, true, TranspDoc) then begin
                            TransportHeader.get(TranspDoc);
                            page.run(page::"BC2SC_Transport Card", TransportHeader);
                        end;
                    end;
                end;
            }
            // action(BC2SC_CreatePickup)
            // {
            //     Image = NewWarehouseShipment;
            //     Caption = 'Create Transport';
            //     ApplicationArea = All;

            //     trigger OnAction()
            //     var
            //         ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
            //         TransportHeader: Record "BC2SC_Transport Header";
            //         TranspDoc: Code[20];
            //         ConfMsg004: Label 'Create Pickup for this Service Order?';
            //         ConfMsg005: Label 'Pickup %1 created. Open Document?';
            //         ConfMsg006: Label 'Pickup %1 for this Document exists. Create a new Transport Document?';
            //     begin
            //         if Confirm(ConfMsg004) then begin
            //             TransportHeader.setrange("Created from Document Type", TransportHeader."Created from Document Type"::"Whse.Act.Header");
            //             TransportHeader.setrange("Created from Document No.", Rec."No.");
            //             TransportHeader.setrange("Transport Document Type", TransportHeader."Transport Document Type"::Return);
            //             if TransportHeader.FindFirst() then
            //                 if not Confirm(ConfMsg006, true, TransportHeader."No.") then
            //                     exit;

            //             TransportHeader.reset;

            //             TranspDoc := ShipCloudMgt.CreateTranspFromServiceOrder(Rec, TransportHeader."Transport Document Type"::Return);
            //             if Confirm(ConfMsg005, true, TranspDoc) then begin
            //                 TransportHeader.get(TranspDoc);
            //                 page.run(page::"BC2SC_Transport Card", TransportHeader);
            //             end;
            //         end;
            //     end;
            // }

        }
    }
}
