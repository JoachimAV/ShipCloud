/// <summary>
/// Codeunit xtCommerce Management (ID 61000).
/// </summary>
codeunit 61000 "BC2SC_ShipCloud Management"
{
    /// <summary>
    /// SendTransport.
    /// </summary>
    /// <param name="TransportHeader">VAR Record "BC2SC_Transport Header".</param>
    procedure SendTransport(var TransportHeader: Record "BC2SC_Transport Header")
    var
        Parcel: Record BC2SC_Parcel;
        ShippingAgent: Record "Shipping Agent";
        TempJsonBuffer: Record "Json Buffer" Temporary;
        SalesHeader: Record "Sales Header";
        JsonString: Text;
        JsonResult: Text;
        LblTrackingCarrier: Label 'Carrier Tracking for parcel %1';
        LblTrackingUrl: Label 'Tracking for parcel %1';
        Name1: Text;
        Name2: Text;
        APIKey: Text[50];
    begin
        TransportHeader.testfield(Status, TransportHeader.Status::Open);

        GetSetup();
        TransportHeader.TestField("Transport Document Type", TransportHeader."Transport Document Type"::Shipment);
        ShippingAgent.get(TransportHeader."Shipping Agent Code");

        Parcel.setrange("Transport No.", TransportHeader."No.");
        Parcel.FindFirst();
        repeat
            JsonString :=
                '{' +
                '"to": {' +
                    strsubstno('"company": "%1",', TransportHeader."Ship-to Name") +
                    strsubstno('"first_name": "%1",', TransportHeader."Ship-to Contact") +
                    strsubstno('"last_name": "%1",', TransportHeader."Ship-to Name 2") +
                    strsubstno('"street": "%1",', TransportHeader."Ship-to Address") +
                    strsubstno('"street_no": "%1",', '') +
                    strsubstno('"city": "%1",', TransportHeader."Ship-to City") +
                    strsubstno('"zip_code": "%1",', TransportHeader."Ship-to Post Code") +
                    strsubstno('"country": "%1"', TransportHeader."Ship-to Country/Region Code") +
                '},' +
                '"package": {' +
                    strsubstno('"weight": %1,', format(Parcel.Weight, 0, 9)) +
                    strsubstno('"length": %1,', Parcel.Length) +
                    strsubstno('"width": %1,', Parcel.Width) +
                    strsubstno('"height": %1,', Parcel.Height) +
                    '"type": "parcel"' +
                '},' +
                StrSubstNo('"carrier": "%1",', ShippingAgent."BC2SC_Shipcloud Agent Name") +
                StrSubstNo('"service": "%1",', TransportHeader."Shipping Agent Service Code") +
                StrSubstNo('"reference_number": "%1",', TransportHeader."Your Reference") +
                StrSubstNo('"notification_email": "%1",', TransportHeader."Notification E-Mail") +
                '"create_shipping_label": true' +
                '}';
            if ShipCloudSetup."Use Sandbox" then
                APIKey := ShipCloudSetup."Sandbox API Key"
            else
                apikey := ShipCloudSetup."API Key";
            if ShipCloudSetup.Debug then begin
                Message(ShipCloudSetup."API Base URL" + 'shipments');
                Message(JsonString);
                JSonResult := SEND_Request('POST', ShipCloudSetup."API Base URL" + 'shipments', JsonString, APIKey);
            end else begin
                JsonResult := SEND_Request('POST', ShipCloudSetup."API Base URL" + 'shipments', JsonString, APIKey)
            end;

            TempJsonBuffer.Deleteall;
            TempJsonBuffer.ReadFromText(jsonResult);

            if ShipCloudSetup.Debug then begin
                Commit;
                page.RunModal(page::"BC2SC_JsonBuffer Result", TempJsonBuffer);
            end;
            //Process Result
            TempJsonBuffer.FindFirst();
            Repeat
                case TempJsonBuffer.Value of
                    'id':
                        begin
                            TempJsonBuffer.Next();
                            Parcel.ID := TempJsonBuffer.Value;
                            Parcel.modify(true);
                        end;
                    'carrier_tracking_no':
                        begin
                            TempJsonBuffer.Next();
                            Parcel."Tracking No." := TempJsonBuffer.Value;
                            Parcel.modify(true);
                            case TransportHeader."Source Document Type" of
                                TransportHeader."Source Document Type"::"Sales Order":
                                    if SalesHeader.get(SalesHeader."Document Type"::Order, TransportHeader."Source Document No.") then begin
                                        SalesHeader."Package Tracking No." := Parcel."Tracking No.";
                                        SalesHeader.modify;
                                    end;
                            end;
                        end;
                    'carrier_tracking_url':
                        begin
                            TempJsonBuffer.Next();
                            TransportHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblTrackingCarrier, Parcel."No."));
                            Parcel.AddLink(TempJsonBuffer.Value, Strsubstno(LblTrackingCarrier, Parcel."No."));
                            case TransportHeader."Source Document Type" of
                                TransportHeader."Source Document Type"::"Sales Order":
                                    if SalesHeader.get(SalesHeader."Document Type"::Order, TransportHeader."Source Document No.") then
                                        SalesHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblTrackingCarrier, Parcel."No."));
                            end;
                        end;
                    'label_url':
                        begin
                            TempJsonBuffer.Next();
                            TransportHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblLabelUrl, Parcel."No."));
                            Parcel.AddLink(TempJsonBuffer.Value, Strsubstno(LblLabelUrl, Parcel."No."));
                            case TransportHeader."Source Document Type" of
                                TransportHeader."Source Document Type"::"Sales Order":
                                    if SalesHeader.get(SalesHeader."Document Type"::Order, TransportHeader."Source Document No.") then
                                        SalesHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblLabelUrl, Parcel."No."));
                            end;
                        end;
                    'price':
                        begin
                            TempJsonBuffer.Next();
                            if evaluate(Parcel.Price, TempJsonBuffer.Value) then;
                            Parcel.modify(true);
                        end;
                    'errors':
                        begin
                            TempJsonBuffer.Next();
                            TempJsonBuffer.Next();
                            Error(TempJsonBuffer.Value);
                        end;
                end;
            until TempJsonBuffer.Next() = 0;
        Until Parcel.Next() = 0;

        TransportHeader.validate(Status, TransportHeader.Status::Sended);
        TransportHeader.modify(true);

    end;

    /// <summary>
    /// SendPickup.
    /// </summary>
    /// <param name="TransportHeader">VAR Record "BC2SC_Transport Header".</param>
    procedure SendPickup(var TransportHeader: Record "BC2SC_Transport Header")
    var
        Parcel: Record BC2SC_Parcel;
        ShippingAgent: Record "Shipping Agent";
        TempJsonBuffer: Record "Json Buffer" Temporary;
        SalesHeader: Record "Sales Header";
        JsonString: Text;
        JsonResult: Text;
        LblTrackingCarrier: Label 'Carrier Tracking for parcel %1';
        LblTrackingUrl: Label 'Tracking for parcel %1';
        LblLabelUrl: Label 'Label URL Parcel %1';
        Name1: Text;
        Name2: Text;
        APIKey: Text[50];
    begin

        GetSetup();
        TransportHeader.TestField("Transport Document Type", TransportHeader."Transport Document Type"::Return);
        ShippingAgent.get(TransportHeader."Shipping Agent Code");

        Parcel.setrange("Transport No.", TransportHeader."No.");
        Parcel.FindFirst();
        repeat
            JsonString :=
                '{' +
                    strsubstno('"carrier":"%1"', ShippingAgent."BC2SC_Shipcloud Agent Name") +
                '"pickup_time": {' +
                        ' "earliest": "2015-09-15T09:00:00+02:00",' +
                        '"latest": "2015-09-15T18:00:00+02:00"' +
                    '},' +
                //                '{' +
                '"pickup_address": {' +
                    strsubstno('"company": "%1",', TransportHeader."Ship-to Name") +
                    strsubstno('"first_name": "%1",', TransportHeader."Ship-to Contact") +
                    strsubstno('"last_name": "%1",', TransportHeader."Ship-to Name 2") +
                    strsubstno('"street": "%1",', TransportHeader."Ship-to Address") +
                    strsubstno('"street_no": "%1",', '') +
                    strsubstno('"city": "%1",', TransportHeader."Ship-to City") +
                    strsubstno('"zip_code": "%1",', TransportHeader."Ship-to Post Code") +
                    strsubstno('"country": "%1"', TransportHeader."Ship-to Country/Region Code") +
                '}' +
                // '"package": {' +
                //     strsubstno('"weight": %1,', format(Parcel.Weight, 0, 9)) +
                //     strsubstno('"length": %1,', Parcel.Length) +
                //     strsubstno('"width": %1,', Parcel.Width) +
                //     strsubstno('"height": %1,', Parcel.Height) +
                //     '"type": "parcel"' +
                // '},' +
                // StrSubstNo('"carrier": "%1",', ShippingAgent."BC2SC_Shipcloud Agent Name") +
                // StrSubstNo('"service": "%1",', TransportHeader."Shipping Agent Service Code") +
                // StrSubstNo('"reference_number": "%1",', TransportHeader."Your Reference") +
                // StrSubstNo('"notification_email": "%1",', TransportHeader."Notification E-Mail") +
                // '"create_shipping_label": true' +
                '}';
            if ShipCloudSetup."Use Sandbox" then
                APIKey := ShipCloudSetup."Sandbox API Key"
            else
                apikey := ShipCloudSetup."API Key";
            if ShipCloudSetup.Debug then begin
                Message(ShipCloudSetup."API Base URL" + 'shipments');
                Message(JsonString);
                JSonResult := SEND_Request('POST', ShipCloudSetup."API Base URL" + 'shipments', JsonString, APIKey);
            end else begin
                JsonResult := SEND_Request('POST', ShipCloudSetup."API Base URL" + 'shipments', JsonString, APIKey)
            end;

            TempJsonBuffer.Deleteall;
            TempJsonBuffer.ReadFromText(jsonResult);

            if ShipCloudSetup.Debug then begin
                Commit;
                page.RunModal(page::"BC2SC_JsonBuffer Result", TempJsonBuffer);
            end;
            //Process Result
            TempJsonBuffer.FindFirst();
            Repeat
                case TempJsonBuffer.Value of
                    'id':
                        begin
                            TempJsonBuffer.Next();
                            Parcel.ID := TempJsonBuffer.Value;
                            Parcel.modify(true);
                        end;
                    'carrier_tracking_no':
                        begin
                            TempJsonBuffer.Next();
                            Parcel."Tracking No." := TempJsonBuffer.Value;
                            Parcel.modify(true);
                            case TransportHeader."Source Document Type" of
                                TransportHeader."Source Document Type"::"Sales Order":
                                    if SalesHeader.get(SalesHeader."Document Type"::Order, TransportHeader."Source Document No.") then begin
                                        SalesHeader."Package Tracking No." := Parcel."Tracking No.";
                                        SalesHeader.modify;
                                    end;
                            end;
                        end;
                    'carrier_tracking_url':
                        begin
                            TempJsonBuffer.Next();
                            TransportHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblTrackingCarrier, Parcel."No."));
                            Parcel.AddLink(TempJsonBuffer.Value, Strsubstno(LblTrackingCarrier, Parcel."No."));
                            case TransportHeader."Source Document Type" of
                                TransportHeader."Source Document Type"::"Sales Order":
                                    if SalesHeader.get(SalesHeader."Document Type"::Order, TransportHeader."Source Document No.") then
                                        SalesHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblTrackingCarrier, Parcel."No."));
                            end;
                        end;
                    'label_url':
                        begin
                            TempJsonBuffer.Next();
                            TransportHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblLabelUrl, Parcel."No."));
                            Parcel.AddLink(TempJsonBuffer.Value, Strsubstno(LblLabelUrl, Parcel."No."));
                            case TransportHeader."Source Document Type" of
                                TransportHeader."Source Document Type"::"Sales Order":
                                    if SalesHeader.get(SalesHeader."Document Type"::Order, TransportHeader."Source Document No.") then
                                        SalesHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblLabelUrl, Parcel."No."));
                            end;
                        end;
                    'price':
                        begin
                            TempJsonBuffer.Next();
                            if evaluate(Parcel.Price, TempJsonBuffer.Value) then;
                            Parcel.modify(true);
                        end;
                    'errors':
                        begin
                            TempJsonBuffer.Next();
                            TempJsonBuffer.Next();
                            Error(TempJsonBuffer.Value);
                        end;
                end;
            until TempJsonBuffer.Next() = 0;
        Until Parcel.Next() = 0;

        TransportHeader.validate(Status, TransportHeader.Status::Sended);
        TransportHeader.modify(true);

    end;

    /// <summary>
    /// SendPickupRequest.
    /// </summary>
    /// <param name="TransportHeader">VAR Record "BC2SC_Transport Header".</param>
    procedure SendPickupRequest(var TransportHeader: Record "BC2SC_Transport Header")
    var
        Parcel: Record BC2SC_Parcel;
        ShippingAgent: Record "Shipping Agent";
        TempJsonBuffer: Record "Json Buffer" Temporary;
        SalesHeader: Record "Sales Header";
        JsonString: Text;
        JsonResult: Text;
        LblTrackingCarrier: Label 'Carrier Tracking for parcel %1';
        LblTrackingUrl: Label 'Tracking for parcel %1';
        LblLabelUrl: Label 'Label URL Parcel %1';
        Name1: Text;
        Name2: Text;
        APIKey: text[50];
    begin
        GetSetup();
        //Todo: Noch offen Rücktransport
        //TransportHeader.TestField("Transport Document Type", TransportHeader."Transport Document Type"::Pickup);
        ShippingAgent.get(TransportHeader."Shipping Agent Code");

        Parcel.setrange("Transport No.", TransportHeader."No.");
        Parcel.FindFirst();
        repeat
            JsonString :=
                '{' +
                '"to": {' +
                    strsubstno('"company": "%1",', TransportHeader."Ship-to Name") +
                    strsubstno('"first_name": "%1",', TransportHeader."Ship-to Contact") +
                    strsubstno('"last_name": "%1",', TransportHeader."Ship-to Name 2") +
                    strsubstno('"street": "%1",', TransportHeader."Ship-to Address") +
                    strsubstno('"street_no": "%1",', '') +
                    strsubstno('"city": "%1",', TransportHeader."Ship-to City") +
                    strsubstno('"zip_code": "%1",', TransportHeader."Ship-to Post Code") +
                    strsubstno('"country": "%1"', TransportHeader."Ship-to Country/Region Code") +
                '},' +
                '"package": {' +
                    strsubstno('"weight": %1,', format(Parcel.Weight, 0, 9)) +
                    strsubstno('"length": %1,', Parcel.Length) +
                    strsubstno('"width": %1,', Parcel.Width) +
                    strsubstno('"height": %1,', Parcel.Height) +
                    '"type": "parcel"' +
                '},' +
                StrSubstNo('"carrier": "%1",', ShippingAgent."BC2SC_Shipcloud Agent Name") +
                StrSubstNo('"service": "%1",', TransportHeader."Shipping Agent Service Code") +
                StrSubstNo('"reference_number": "%1",', TransportHeader."Your Reference") +
                StrSubstNo('"notification_email": "%1",', TransportHeader."Notification E-Mail") +
                '"create_shipping_label": true' +
                '}';
            if ShipCloudSetup."Use Sandbox" then
                APIKey := ShipCloudSetup."Sandbox API Key"
            else
                APIKey := ShipCloudSetup."API Key";
            if ShipCloudSetup.Debug then begin
                Message(ShipCloudSetup."API Base URL" + 'shipments');
                Message(JsonString);
                JSonResult := SEND_Request('POST', ShipCloudSetup."API Base URL" + 'shipments', JsonString, APIKey);
            end else begin
                JsonResult := SEND_Request('POST', ShipCloudSetup."API Base URL" + 'shipments', JsonString, APIKey)
            end;

            TempJsonBuffer.Deleteall;
            TempJsonBuffer.ReadFromText(jsonResult);

            if ShipCloudSetup.Debug then begin
                Commit;
                page.RunModal(page::"BC2SC_JsonBuffer Result", TempJsonBuffer);
            end;
            //Process Result
            TempJsonBuffer.FindFirst();
            Repeat
                case TempJsonBuffer.Value of
                    'id':
                        begin
                            TempJsonBuffer.Next();
                            Parcel.ID := TempJsonBuffer.Value;
                            Parcel.modify(true);
                        end;
                    'carrier_tracking_no':
                        begin
                            TempJsonBuffer.Next();
                            Parcel."Tracking No." := TempJsonBuffer.Value;
                            Parcel.modify(true);
                            case TransportHeader."Source Document Type" of
                                TransportHeader."Source Document Type"::"Sales Order":
                                    if SalesHeader.get(SalesHeader."Document Type"::Order, TransportHeader."Source Document No.") then begin
                                        SalesHeader."Package Tracking No." := Parcel."Tracking No.";
                                        SalesHeader.modify;
                                    end;
                            end;
                        end;
                    'carrier_tracking_url':
                        begin
                            TempJsonBuffer.Next();
                            TransportHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblTrackingCarrier, Parcel."No."));
                            Parcel.AddLink(TempJsonBuffer.Value, Strsubstno(LblTrackingCarrier, Parcel."No."));
                            case TransportHeader."Source Document Type" of
                                TransportHeader."Source Document Type"::"Sales Order":
                                    if SalesHeader.get(SalesHeader."Document Type"::Order, TransportHeader."Source Document No.") then
                                        SalesHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblTrackingCarrier, Parcel."No."));
                            end;
                        end;
                    'label_url':
                        begin
                            TempJsonBuffer.Next();
                            TransportHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblLabelUrl, Parcel."No."));
                            Parcel.AddLink(TempJsonBuffer.Value, Strsubstno(LblLabelUrl, Parcel."No."));
                            case TransportHeader."Source Document Type" of
                                TransportHeader."Source Document Type"::"Sales Order":
                                    if SalesHeader.get(SalesHeader."Document Type"::Order, TransportHeader."Source Document No.") then
                                        SalesHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblLabelUrl, Parcel."No."));
                            end;
                        end;
                    'price':
                        begin
                            TempJsonBuffer.Next();
                            if evaluate(Parcel.Price, TempJsonBuffer.Value) then;
                            Parcel.modify(true);
                        end;
                    'errors':
                        begin
                            TempJsonBuffer.Next();
                            TempJsonBuffer.Next();
                            Error(TempJsonBuffer.Value);
                        end;
                end;
            until TempJsonBuffer.Next() = 0;
        Until Parcel.Next() = 0;

        TransportHeader.validate(Status, TransportHeader.Status::Sended);
        TransportHeader.modify(true);

    end;

    #region TransportManagement
    Procedure CreateTranspFromWhseActHeader(var WhseActHeader: Record "Warehouse Activity Header") TransportNoCreated: Text[20];
    var
        TransportHeader: Record "BC2SC_Transport Header";
        TransportLine: Record "BC2SC_Transport Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        WhseActLine: Record "Warehouse Activity Line";
        ShippingAgent: Record "Shipping Agent";
        NextLineNo: Integer;
        YourRefText: label '%1 %2';
    begin
        GetSetup();

        WhseActLine.SetRange("No.", WhseActHeader."No.");
        WhseActLine.setrange("Activity Type", WhseActHeader.Type);
        WhseActLine.findfirst();

        TransportHeader.init;
        TransportHeader.insert(true);

        case WhseActLine."Source Document" of
            WhseActLine."Source Document"::"Sales Order":
                begin
                    SalesHeader.get(SalesHeader."Document Type"::Order, WhseActLine."Source No.");
                    SalesHeader.TestField("Shipping Agent Code");

                    ShippingAgent.get(SalesHeader."Shipping Agent Code");
                    ShippingAgent.TestField("BC2SC_Shipcloud Agent Name");
                    ;

                    //Fill From/To Address
                    Transportheader."Customer No." := SalesHeader."Sell-to Customer No.";
                    TransportHeader."Ship-to Name" := SalesHeader."Ship-to Name";
                    TransportHeader."Ship-to Name 2" := SalesHeader."Ship-to Name 2";
                    TransportHeader."Ship-to Address" := SalesHeader."Ship-to Address";
                    TransportHeader."Ship-to Address 2" := SalesHeader."Ship-to Address 2";
                    TransportHeader."Ship-to Name" := SalesHeader."Ship-to Name";
                    TransportHeader."Ship-to Name 2" := SalesHeader."Ship-to Name 2";
                    TransportHeader."Ship-to City" := SalesHeader."Ship-to City";
                    TransportHeader."Ship-to Contact" := SalesHeader."Ship-to Contact";
                    TransportHeader."Ship-to Country/Region Code" := SalesHeader."Ship-to Country/Region Code";
                    TransportHeader."Ship-to County" := SalesHeader."Ship-to County";
                    TransportHeader."Ship-to Post Code" := SalesHeader."Ship-to Post Code";
                    TransportHeader."Shipment Date" := SalesHeader."Shipment Date";
                    TransportHeader."Shipment Method Code" := SalesHeader."Shipment Method Code";
                    TransportHeader."Shipping Agent Code" := SalesHeader."Shipping Agent Code";
                    TransportHeader."Shipping Agent Service Code" := SalesHeader."Shipping Agent Service Code";
                    TransportHeader.validate("Source Document Type", TransportHeader."Source Document Type"::"Sales Order");
                    TransportHeader.validate("Source Document No.", SalesHeader."No.");
                    TransportHeader.Validate("Created from Document Type", TransportHeader."Created from Document Type"::"Whse.Act.Header");
                    TransportHeader.Validate("Created from Document No.", WhseActHeader."No.");
                    if SalesHeader."Your Reference" <> '' then
                        TransportHeader."Your Reference" := SalesHeader."Your Reference"
                    else
                        TransportHeader."Your Reference" := strsubstno(YourRefText, SalesHeader."Document Type", Salesheader."No.");
                    TransportHeader."Notification E-Mail" := SalesHeader."Sell-to E-Mail";
                    TransportHeader.Modify(True);

                    WhseActLine.setrange("Action Type", WhseActLine."Action Type"::Take);
                    WhseActLine.setfilter("Qty. to Handle", '<>%1', 0);
                    if WhseActLine.FindFirst() then begin
                        repeat
                            NextLineNo += 10000;
                            TransportLine.init;
                            TransportLine."Transport No." := TransportHeader."No.";
                            TransportLine."Line No." := NextLineNo;
                            TransportLine.validate(type, TransportLine.Type::Item);
                            TransportLine.validate("No.", WhseActLine."Item No.");
                            TransportLine.Description := WhseActLine.Description;
                            TransportLine."Description 2" := WhseActLine."Description 2";
                            TransportLine.validate(Quantity, WhseActLine."Qty. to Handle");

                            TransportLine.validate("Weight per Unit", WhseActLine.Weight);
                            TransportLine.insert(true);
                        until WhseActLine.Next() = 0;
                    end else begin
                        if shipCloudSetup."Def. Transport Item No." <> '' Then begin
                            NextLineNo += 10000;
                            TransportLine.init;
                            TransportLine."Transport No." := TransportHeader."No.";
                            TransportLine."Line No." := NextLineNo;
                            TransportLine.validate(type, TransportLine.Type::Item);
                            TransportLine.validate("No.", ShipCloudSetup."Def. Transport Item No.");
                            //TransportLine.Description := WhseActLine.Description;
                            //TransportLine."Description 2" := WhseActLine."Description 2";
                            TransportLine.validate(Quantity, 1);

                            //TransportLine.validate("Weight per Unit", WhseActLine.Weight);
                            TransportLine.insert(true);
                        end;
                    end;
                    TransportNoCreated := TransportHeader."No.";
                end;
        end;
    end;

    Procedure CreateTranspFromServiceOrder(var ServiceHeader: Record "Service Header"; Direction: enum BC2SC_Direction) TransportNoCreated: Text[20];
    var
        TransportHeader: Record "BC2SC_Transport Header";
        TransportLine: Record "BC2SC_Transport Line";
        ServiceLine: Record "Service Line";
        ShippingAgent: Record "Shipping Agent";
        NextLineNo: Integer;
        YourRefText: label '%1 %2';
    begin
        GetSetup();

        // WhseActLine.SetRange("No.", WhseActHeader."No.");
        // WhseActLine.findfirst();

        // WhseActLine.setrange("Activity Type", WhseActLine."Activity Type"::Pick);

        ServiceHeader.TestField("Shipping Agent Code");
        ShippingAgent.get(Serviceheader."Shipping Agent Code");
        ShippingAgent.TestField("BC2SC_Shipcloud Agent Name");

        TransportHeader.init;
        TransportHeader.insert(true);
        TransportHeader."Transport Document Type" := Direction;
        //Fill From/To Address
        TransportHeader."Customer No." := ServiceHeader."Customer No.";
        TransportHeader."Ship-to Name" := Serviceheader."Ship-to Name";
        TransportHeader."Ship-to Name 2" := Serviceheader."Ship-to Name 2";
        TransportHeader."Ship-to Address" := Serviceheader."Ship-to Address";
        TransportHeader."Ship-to Address 2" := Serviceheader."Ship-to Address 2";
        TransportHeader."Ship-to Name" := Serviceheader."Ship-to Name";
        TransportHeader."Ship-to Name 2" := Serviceheader."Ship-to Name 2";
        TransportHeader."Ship-to City" := Serviceheader."Ship-to City";
        TransportHeader."Ship-to Contact" := Serviceheader."Ship-to Contact";
        TransportHeader."Ship-to Country/Region Code" := Serviceheader."Ship-to Country/Region Code";
        TransportHeader."Ship-to County" := Serviceheader."Ship-to County";
        TransportHeader."Ship-to Post Code" := Serviceheader."Ship-to Post Code";
        TransportHeader."Shipment Date" := Serviceheader."Document Date";
        TransportHeader."Shipment Method Code" := Serviceheader."Shipment Method Code";
        TransportHeader."Shipping Agent Code" := Serviceheader."Shipping Agent Code";
        TransportHeader."Shipping Agent Service Code" := Serviceheader."Shipping Agent Service Code";
        case ServiceHeader."Document Type" of
            Serviceheader."Document Type"::Order:
                TransportHeader.validate("Source Document Type", TransportHeader."Source Document Type"::"Service Order");
            else
                error('Not implementated');
        end;
        TransportHeader.validate("Source Document No.", Serviceheader."No.");
        TransportHeader.Validate("Created from Document Type", TransportHeader."Created from Document Type"::"Service Header");
        TransportHeader.Validate("Created from Document No.", Serviceheader."No.");
        if Serviceheader."Your Reference" <> '' then
            TransportHeader."Your Reference" := Serviceheader."Your Reference"
        else
            TransportHeader."Your Reference" := strsubstno(YourRefText, Serviceheader."Document Type", Serviceheader."No.");
        TransportHeader."Notification E-Mail" := Serviceheader."E-Mail";
        TransportHeader.Modify(True);

        ServiceLine.setrange("Document Type", Serviceheader."Document Type");
        ServiceLine.Setrange("Document No.", ServiceHeader."No.");
        serviceline.setrange(Type, ServiceLine.type::Item);
        serviceline.setfilter(Quantity, '<>%1', 0);
        if ServiceLine.FindFirst() then begin
            repeat
                NextLineNo += 10000;
                TransportLine.init;
                TransportLine."Transport No." := TransportHeader."No.";
                TransportLine."Line No." := NextLineNo;
                TransportLine.validate(type, TransportLine.Type::Item);
                TransportLine.validate("No.", ServiceLine."No.");
                TransportLine.Description := ServiceLine.Description;
                TransportLine."Description 2" := ServiceLine."Description 2";
                TransportLine.validate(Quantity, ServiceLine.Quantity);

                TransportLine.validate("Weight per Unit", ServiceLine."Gross Weight");
                TransportLine.insert(true);
            until ServiceLine.Next() = 0;
        end else begin
            if shipCloudSetup."Def. Transport Item No." <> '' Then begin
                NextLineNo += 10000;
                TransportLine.init;
                TransportLine."Transport No." := TransportHeader."No.";
                TransportLine."Line No." := NextLineNo;
                TransportLine.validate(type, TransportLine.Type::Item);
                TransportLine.validate("No.", ShipCloudSetup."Def. Transport Item No.");
                //TransportLine.Description := WhseActLine.Description;
                //TransportLine."Description 2" := WhseActLine."Description 2";
                TransportLine.validate(Quantity, 1);

                //TransportLine.validate("Weight per Unit", WhseActLine.Weight);
                TransportLine.insert(true);
            end;
        end;

        TransportNoCreated := TransportHeader."No.";
    end;


    Procedure CreateTranspFromSalesOrder(var SalesHeader: Record "Sales Header") TransportNoCreated: Text[20];
    var
        TransportHeader: Record "BC2SC_Transport Header";
        TransportLine: Record "BC2SC_Transport Line";
        SalesLine: Record "Sales Line";
        ShippingAgent: Record "Shipping Agent";
        NextLineNo: Integer;
        YourRefText: label '%1 %2';
    begin
        GetSetup();

        // WhseActLine.SetRange("No.", WhseActHeader."No.");
        // WhseActLine.findfirst();

        // WhseActLine.setrange("Activity Type", WhseActLine."Activity Type"::Pick);

        SalesHeader.TestField("Shipping Agent Code");
        ShippingAgent.get(SalesHeader."Shipping Agent Code");
        ShippingAgent.TestField("BC2SC_Shipcloud Agent Name");

        TransportHeader.init;
        TransportHeader.insert(true);

        //Fill From/To Address
        TransportHeader."Customer No." := SalesHeader."Sell-to Customer No.";
        TransportHeader."Ship-to Name" := SalesHeader."Ship-to Name";
        TransportHeader."Ship-to Name 2" := SalesHeader."Ship-to Name 2";
        TransportHeader."Ship-to Address" := SalesHeader."Ship-to Address";
        TransportHeader."Ship-to Address 2" := SalesHeader."Ship-to Address 2";
        TransportHeader."Ship-to Name" := SalesHeader."Ship-to Name";
        TransportHeader."Ship-to Name 2" := SalesHeader."Ship-to Name 2";
        TransportHeader."Ship-to City" := SalesHeader."Ship-to City";
        TransportHeader."Ship-to Contact" := SalesHeader."Ship-to Contact";
        TransportHeader."Ship-to Country/Region Code" := SalesHeader."Ship-to Country/Region Code";
        TransportHeader."Ship-to County" := SalesHeader."Ship-to County";
        TransportHeader."Ship-to Post Code" := SalesHeader."Ship-to Post Code";
        TransportHeader."Shipment Date" := SalesHeader."Document Date";
        TransportHeader."Shipment Method Code" := SalesHeader."Shipment Method Code";
        TransportHeader."Shipping Agent Code" := SalesHeader."Shipping Agent Code";
        TransportHeader."Shipping Agent Service Code" := SalesHeader."Shipping Agent Service Code";
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                TransportHeader.validate("Source Document Type", TransportHeader."Source Document Type"::"Sales Order");
            else
                error('Not implementated');
        end;
        TransportHeader.validate("Source Document No.", SalesHeader."No.");
        TransportHeader.Validate("Created from Document Type", TransportHeader."Created from Document Type"::"Sales Header");
        TransportHeader.Validate("Created from Document No.", SalesHeader."No.");
        if SalesHeader."Your Reference" <> '' then
            TransportHeader."Your Reference" := SalesHeader."Your Reference"
        else
            TransportHeader."Your Reference" := strsubstno(YourRefText, SalesHeader."Document Type", SalesHeader."No.");
        TransportHeader."Notification E-Mail" := SalesHeader."Sell-to E-Mail";
        TransportHeader.Modify(True);
        SalesLine.setrange("Document Type", SalesHeader."Document Type");
        SalesLine.Setrange("Document No.", SalesHeader."No.");
        SalesLine.setrange(Type, SalesLine.type::Item);
        SalesLine.setfilter(Quantity, '<>%1', 0);
        if SalesLine.FindFirst() then begin
            repeat
                NextLineNo += 10000;
                TransportLine.init;
                TransportLine."Transport No." := TransportHeader."No.";
                TransportLine."Line No." := NextLineNo;
                TransportLine.validate(type, TransportLine.Type::Item);
                TransportLine.validate("No.", SalesLine."No.");
                TransportLine.Description := SalesLine.Description;
                TransportLine."Description 2" := SalesLine."Description 2";
                TransportLine.validate(Quantity, SalesLine.Quantity);

                TransportLine.validate("Weight per Unit", SalesLine."Gross Weight");
                TransportLine.insert(true);
            until SalesLine.Next() = 0;
        end else begin
            if shipCloudSetup."Def. Transport Item No." <> '' Then begin
                NextLineNo += 10000;
                TransportLine.init;
                TransportLine."Transport No." := TransportHeader."No.";
                TransportLine."Line No." := NextLineNo;
                TransportLine.validate(type, TransportLine.Type::Item);
                TransportLine.validate("No.", ShipCloudSetup."Def. Transport Item No.");
                //TransportLine.Description := WhseActLine.Description;
                //TransportLine."Description 2" := WhseActLine."Description 2";
                TransportLine.validate(Quantity, 1);

                //TransportLine.validate("Weight per Unit", WhseActLine.Weight);
                TransportLine.insert(true);
            end;
        end;
        TransportNoCreated := TransportHeader."No.";
    end;

    Procedure CreateTranspFromSegmentHeader(var SegmentHeader: Record "Segment Header");
    var
        SegmentLine: Record "Segment Line";
        d: Dialog;
        i: integer;
        //CreateAndSend: Boolean;
        lbl003: label 'Creating Transports #1########';
        lbl004: label 'Create and send parcels (if not only Transports are created)';
    begin
        SegmentHeader.CalcFields("BC2SC_Qty. Transports");
        SegmentHeader.TestField("BC2SC_Qty. Transports", 0);
        SegmentHeader.TestField("BC2SC_Packaging Code");
        SegmentHeader.TestField("BC2SC_Parcel Weight");
        SegmentHeader.TestField("BC2SC_Shipping Item No.");
        SegmentHeader.TestField("BC2SC_Shipping Agent Code");
        SegmentHeader.TestField("BC2SC_Ship. Agent Service Code");


        //CreateAndSend := Confirm(lbl004);

        SegmentLine.setrange("Segment No.", SegmentHeader."No.");
        SegmentLine.setfilter("Contact No.", '<>%1', '');
        SegmentLine.FindFirst();
        d.open(lbl003);
        repeat
            i += 1;
            d.Update(1, i);
            CreateTranspFromSegmentLine(SegmentLine, SegmentHeader);
        until SegmentLine.Next() = 0;
        d.Close();
    end;

    local Procedure CreateTranspFromSegmentLine(var SegmentLine: Record "Segment Line"; SegmentHeader: record "Segment Header");
    var
        TransportHeader: Record "BC2SC_Transport Header";
        TransportLine: Record "BC2SC_Transport Line";
        Contact: Record Contact;
        ShippingAgent: Record "Shipping Agent";
        Parcel: Record BC2SC_Parcel;
        NextLineNo: Integer;
        YourRefText: label '%1 %2';
    begin
        GetSetup();

        // WhseActLine.SetRange("No.", WhseActHeader."No.");
        // WhseActLine.findfirst();

        // WhseActLine.setrange("Activity Type", WhseActLine."Activity Type"::Pick);

        ShippingAgent.get(SegmentHeader."BC2SC_Shipping Agent Code");
        ShippingAgent.TestField("BC2SC_Shipcloud Agent Name");

        TransportHeader.init;
        TransportHeader.insert(true);
        TransportHeader."Transport Document Type" := TransportHeader."Transport Document Type"::Shipment;
        //Fill From/To Address
        //TransportHeader."Customer No." := ServiceHeader."Customer No.";
        Contact.get(SegmentLine."Contact No.");

        TransportHeader."Ship-to Name" := Contact."Name";
        TransportHeader."Ship-to Name 2" := Contact."Name 2";
        TransportHeader."Ship-to Address" := Contact."Address";
        TransportHeader."Ship-to Address 2" := Contact."Address 2";
        TransportHeader."Ship-to City" := Contact."City";
        TransportHeader."Ship-to Contact" := Contact."First Name" + ' ' + Contact.Surname;
        TransportHeader."Ship-to Country/Region Code" := Contact."Country/Region Code";
        TransportHeader."Ship-to County" := Contact."County";
        TransportHeader."Ship-to Post Code" := Contact."Post Code";
        TransportHeader."Shipment Date" := Today();
        //TransportHeader."Shipment Method Code" := Contact."Shipment Method Code";
        TransportHeader."Shipping Agent Code" := SegmentHeader."BC2SC_Shipping Agent Code";
        TransportHeader."Shipping Agent Service Code" := SegmentHeader."BC2SC_Ship. Agent Service Code";

        TransportHeader.validate("Source Document Type", TransportHeader."Source Document Type"::Segment);
        TransportHeader.validate("Source Document No.", SegmentHeader."No.");
        TransportHeader.Validate("Created from Document Type", TransportHeader."Created from Document Type"::Segment);
        TransportHeader.Validate("Created from Document No.", SegmentHeader."No.");
        TransportHeader."Your Reference" := strsubstno(YourRefText, SegmentHeader."No.", Contact."No.");

        TransportHeader."Notification E-Mail" := Contact."E-Mail";
        TransportHeader.Modify(True);


        TransportLine.init;
        TransportLine."Transport No." := TransportHeader."No.";
        TransportLine."Line No." := 10000;
        TransportLine.validate(type, TransportLine.Type::Item);
        TransportLine.validate("No.", SegmentHeader."BC2SC_Shipping Item No.");
        TransportLine.validate("Weight per Unit", SegmentHeader."BC2SC_Parcel Weight");
        TransportLine.validate(Quantity, 1);
        TransportLine.validate("Qty. to pack", 1);

        TransportLine.insert(true);

        Parcel.init;
        Parcel.insert(true);
        Parcel.Validate("Packaging Code", SegmentHeader."BC2SC_Packaging Code");
        Parcel.Weight := SegmentHeader."BC2SC_Parcel Weight";
        Parcel."Transport No." := TransportHeader."No.";
        Parcel.Modify(true);

        TransportLine."Parcel No." := Parcel."No.";
        TransportLine.modify;
    end;

    Procedure CreateParcel(var TransportHeader: Record "BC2SC_Transport Header");
    var
        TransportLine: Record "BC2SC_Transport Line";
        NewTransportLine: Record "BC2SC_Transport Line";
        Parcel: Record BC2SC_Parcel;
        Packaging: Record BC2SC_Packaging;
    begin
        TransportHeader.TestField(Status, TransportHeader.Status::Open);
        GetSetup();

        TransportLine.setrange("Transport No.", TransportHeader."No.");
        TransportLine.setrange("Parcel No.", '');
        TransportLine.setfilter("Qty. to pack", '<>%1', 0);
        TransportLine.FindFirst();

        if page.RunModal(0, Packaging) = Action::LookupOK then begin
            Parcel.init;
            Parcel.insert(true);
            Parcel.Validate("Packaging Code", Packaging.code);
            repeat
                Parcel.Weight += TransportLine."Total Weight";
                //Split Line
                if TransportLine."Qty. to pack" < TransportLine.Quantity then begin
                    NewTransportLine := TransportLine;
                    NewTransportLine."Line No." := GetNextTransportLineNo(TransportLine);
                    NewTransportLine.validate(Quantity, TransportLine.Quantity - TransportLine."Qty. to pack");
                    NewTransportLine.validate("Qty. to pack", 0);
                    NewTransportLine.insert;
                    TransportLine.Quantity := TransportLine."Qty. to pack";
                    Transportline.modify;
                end;
                TransportLine."Parcel No." := Parcel."No.";
                TransportLine.modify;
            until TransportLine.Next() = 0;

            Parcel.Weight += Packaging."Package weight";
            Parcel."Transport No." := TransportHeader."No.";
            Parcel.Modify(true);
            if ShipCloudSetup."Def. Qty. to Pack with Qty." then begin
                TransportLine.Reset();
                Transportline.setrange("Transport No.", TransportHeader."No.");
                transportline.setrange("Parcel No.", '');
                if TransportLine.FindFirst() then
                    repeat
                        TransportLine.Validate(Quantity);
                        TransportLine.Modify(true);
                    until TransportLine.Next() = 0;
            end;
            //TransportLine.ModifyAll("Parcel No.", Parcel."No.");
        end;
    end;

    local procedure GetNextTransportLineNo(TransportLine: Record "BC2SC_Transport Line"): Integer
    var
        TrLine2: Record "BC2SC_Transport Line";
    begin
        trline2.setrange("Transport No.", TransportLine."Transport No.");
        TrLine2.setfilter("Line No.", '>%1', TransportLine."Line No.");
        if not trline2.FindFirst() then
            exit(TransportLine."Line No." + 10000)
        else
            exit(transportline."Line No." + round((trline2."Line No." - TransportLine."Line No.") / 2, 1));
    end;
    /// <summary>
    /// CancelTransport.
    /// </summary>
    /// <param name="TransportHeader">VAR Record "BC2SC_Transport Header".</param>
    procedure CancelTransport(var TransportHeader: Record "BC2SC_Transport Header")
    var
        Parcel: Record BC2SC_Parcel;
        url: Text;
    begin
        GetSetup();

        Parcel.setrange("Transport No.", TransportHeader."No.");
        Parcel.FindFirst();
        repeat
            //First Check All Parcel
            Parcel.TestField(id);
        until Parcel.Next() = 0;
        Parcel.FindFirst();
        repeat
            url := strsubstno('%1:%2', ShipCloudSetup."API Base URL", Parcel.ID);
            SEND_Request('DELETE', url, '', ShipCloudSetup."API Key");
        until Parcel.Next() = 0;
        TransportHeader.validate(Status, TransportHeader.Status::Canceled);
        TransportHeader.modify(true);
    end;
    #endregion

    #region Allgemeine API und Funktionen
    local procedure CheckRequestResult(var pTempJsonBuffer: Record "JSON Buffer")
    begin
        pTempJsonBuffer.setrange(Depth, 1);
        ptempJsonBuffer.findfirst();
        repeat
            if (pTempJsonBuffer."Token type" = ptempJsonBuffer."Token type"::"Property Name") and (pTempJsonBuffer.Value = 'message') then begin
                pTempJsonBuffer.next();
                if (STRPOS(pTempJsonBuffer.Value, 'SUCCESS') = 0) then
                    error(pTempJsonBuffer.Value)
                else begin
                    pTempJsonBuffer.reset;
                    exit;
                end;
            end;
        until ptempJsonBuffer.Next() = 0;
        error('Keine gültige Rückgabe erhalten');
    end;


    // local procedure GET_Request(uri: Text) responseText: Text

    // begin

    //     //json := StrSubstNo('localhost:63273/.../LeaveAccrual');

    //     json := StrSubstNo(uri);

    //     if client.Get(json, Response) then begin

    //         Response.Content.ReadAs(json);

    //         Message(json);

    //         exit(json);

    //     end;
    // end;

    procedure PrintTransport(var TransportHeader: record "BC2SC_Transport Header")
    var
        TransportLine: Record "BC2SC_Transport Line";
        Parcel: Record BC2SC_Parcel;
    begin
        Parcel.setrange("Transport No.", TransportHeader."No.");
        Parcel.FindFirst();
        repeat
            PrintPDFByPrintNode(Parcel);
        until Parcel.Next() = 0;
    end;
    /// <summary>
    /// PrintPDFByPrintNode.
    /// </summary>
    /// <param name="Parcel">record BC2SC_Parcel.</param>
    procedure PrintPDFByPrintNode(var Parcel: record BC2SC_Parcel);
    var
        ShipCloudSetup: record "BC2SC_ShipCloud Setup";
        PrintNodePrinter: record "BC2SC_PrintNode Label Printer";
        PrintNodeUser: Record "BC2SC_PrintNode User Setup";
        RecordLink: record "Record Link";
        Json: text;
    begin
        ShipCloudSetup.get;
        ShipCloudSetup.TestField("Activate PrintNode printing", true);
        ShipCloudSetup.TestField("PrintNode API Key");
        ShipCloudSetup.TestField("PrintNode URL");

        PrintNodeUser.get(UserId);
        PrintNodeUser.TestField("Label Printer");

        PrintNodePrinter.get(PrintNodeUser."Label Printer");
        PrintNodePrinter.TestField("Printer ID");

        RecordLink.setrange("Record ID", Parcel.RecordId);
        RecordLink.setrange(Description, Strsubstno(LblLabelUrl, Parcel."No."));
        RecordLink.FindFirst();

        Json := '{' +
                    StrSubstNo('"printerId": %1,', PrintNodePrinter."Printer ID") +
                strsubstno('"title": "%1",', Strsubstno(LblLabelUrl, Parcel."No.")) +
                '"contentType": "pdf_uri",' +
                strsubstno('"content": "%1",', RecordLink.URL1) +
                '"source": "ShipCloud Direct Printing"' +
        '}';

        if ShipCloudSetup.Debug then
            message(SEND_Request('POST', ShipCloudSetup."PrintNode URL", Json, ShipCloudSetup."PrintNode API Key"))
        else
            SEND_Request('POST', ShipCloudSetup."PrintNode URL", Json, ShipCloudSetup."PrintNode API Key");
        Parcel."No. of Printed" += 1;
        Parcel.modify(true);
    end;

    local procedure SEND_Request(Type: Text; uri: Text; _queryObj: Text; pass: Text[50]) responseText: Text;
    var
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        //ResponseText: Text;
        contentHeaders: HttpHeaders;

        Base64Convert: Codeunit "Base64 Convert";
        b64ApiKey: Text;
    //TempBlob: codeunit Temp
    //Credential: dotnet NetworkCredential;
    begin
        RequestHeaders := Client.DefaultRequestHeaders();
        RequestHeaders.Add('Authorization', 'Basic ' + Base64Convert.ToBase64(strsubstno('%1:%1', pass)));

        RequestContent.WriteFrom(_queryObj);

        RequestContent.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');

        RequestMessage.Content := RequestContent;

        RequestMessage.SetRequestUri(uri);
        RequestMessage.Method := Type;
        client.Send(RequestMessage, ResponseMessage);
        responseMessage.Content().ReadAs(responseText);
    end;

    #endregion

    #region InteralFuncions
    local procedure GetSetup();
    begin
        if SetupReaded then
            exit;

        ShipCloudSetup.get;
        ShipCloudSetup.TestField("API Base URL");
        ShipCloudSetup.TestField("API Key");

        ShipCloudSetup.TestField("Parcel No. Series");
        ShipCloudSetup.TestField("Transport No. Series");

        SetupReaded := true;
    end;
    #endregion

    var
        ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
        SetupReaded: Boolean;
        LblLabelUrl: Label 'Label URL Parcel %1';
}