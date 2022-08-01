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
        JsonString: Text;
        JsonResult: Text;
        LblTrackingCarrier: Label 'Carrier Tracking for parcel %1';
        LblTrackingUrl: Label 'Tracking for parcel %1';
        LblLabelUrl: Label 'Label URL Parcel %1';
    begin

        GetSetup();

        ShippingAgent.get(TransportHeader."Shipping Agent Code");

        Parcel.setrange("Transport No.", TransportHeader."No.");
        Parcel.FindFirst();
        repeat
            JsonString :=
                '{' +
                '"to": {' +
                    strsubstno('"company": "%1",', TransportHeader."Ship-to Name" + ' ' + TransportHeader."Ship-to Name 2") +
                    strsubstno('"first_name": "%1",', '') +
                    strsubstno('"last_name": "%1",', '') +
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

            if ShipCloudSetup.Debug then begin
                Message(ShipCloudSetup."API Base URL" + 'shipments');
                Message(JsonString);
                JSonResult := POST_Request(ShipCloudSetup."API Base URL" + 'shipments', JsonString, ShipCloudSetup."API Key");
            end else begin
                JsonResult := POST_Request(ShipCloudSetup."API Base URL" + 'shipments', JsonString, ShipCloudSetup."API Key")
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
                    'carrier_tracking_no':
                        begin
                            TempJsonBuffer.Next();
                            Parcel."Tracking No." := TempJsonBuffer.Value;
                            Parcel.modify(true);
                        end;
                    'carrier_tracking_url':
                        begin
                            TempJsonBuffer.Next();
                            TransportHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblTrackingCarrier, Parcel."No."));
                        end;
                    'label_url':
                        begin
                            TempJsonBuffer.Next();
                            TransportHeader.AddLink(TempJsonBuffer.Value, Strsubstno(LblLabelUrl, Parcel."No."));
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
        WhseActLine.setrange("Activity Type", WhseActLine."Activity Type"::Pick);
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
                    WhseActLine.FindFirst();
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

                    TransportNoCreated := TransportHeader."No.";
                end;
        end;
    end;

    Procedure CreateTranspFromServiceOrder(var ServiceHeader: Record "Service Header") TransportNoCreated: Text[20];
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

        ServiceLine.setrange("Document Type", Serviceheader."Document Type");
        ServiceLine.Setrange("Document No.", ServiceHeader."No.");
        serviceline.setrange(Type, ServiceLine.type::Item);
        serviceline.setfilter(Quantity, '<>%1', 0);
        ServiceLine.FindFirst();

        ServiceHeader.TestField("Shipping Agent Code");
        ShippingAgent.get(Serviceheader."Shipping Agent Code");
        ShippingAgent.TestField("BC2SC_Shipcloud Agent Name");

        TransportHeader.init;
        TransportHeader.insert(true);

        //Fill From/To Address
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

        SalesLine.setrange("Document Type", SalesHeader."Document Type");
        SalesLine.Setrange("Document No.", SalesHeader."No.");
        SalesLine.setrange(Type, SalesLine.type::Item);
        SalesLine.setfilter(Quantity, '<>%1', 0);
        SalesLine.FindFirst();

        SalesHeader.TestField("Shipping Agent Code");
        ShippingAgent.get(SalesHeader."Shipping Agent Code");
        ShippingAgent.TestField("BC2SC_Shipcloud Agent Name");

        TransportHeader.init;
        TransportHeader.insert(true);

        //Fill From/To Address
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
                TransportHeader.validate("Source Document Type", TransportHeader."Source Document Type"::"Service Order");
            else
                error('Not implementated');
        end;
        TransportHeader.validate("Source Document No.", SalesHeader."No.");
        TransportHeader.Validate("Created from Document Type", TransportHeader."Created from Document Type"::"Service Header");
        TransportHeader.Validate("Created from Document No.", SalesHeader."No.");
        if SalesHeader."Your Reference" <> '' then
            TransportHeader."Your Reference" := SalesHeader."Your Reference"
        else
            TransportHeader."Your Reference" := strsubstno(YourRefText, SalesHeader."Document Type", SalesHeader."No.");
        TransportHeader."Notification E-Mail" := SalesHeader."Sell-to E-Mail";
        TransportHeader.Modify(True);

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

        TransportNoCreated := TransportHeader."No.";
    end;

    Procedure CreateParcel(var TransportHeader: Record "BC2SC_Transport Header");
    var
        TransportLine: Record "BC2SC_Transport Line";
        Parcel: Record BC2SC_Parcel;
        Packaging: Record BC2SC_Packaging;
    begin
        TransportHeader.TestField(Status, TransportHeader.Status::Open);

        TransportLine.setrange("Parcel No.", '');
        TransportLine.setfilter("Qty. to pack", '<>%1', 0);
        TransportLine.FindFirst();

        if page.RunModal(0, Packaging) = Action::LookupOK then begin
            Parcel.init;
            Parcel.insert(true);
            Parcel.Validate("Packaging Code", Packaging.code);
            repeat
                Parcel.Weight += TransportLine."Total Weight";
            until Packaging.Next() = 0;
            Parcel.Weight += Packaging."Package weight";
            Parcel."Transport No." := TransportHeader."No.";
            Parcel.Modify(true);
            TransportLine.ModifyAll("Parcel No.", Parcel."No.");
        end;
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

    local procedure POST_Request(uri: Text; _queryObj: Text; pass: Text[50]) responseText: Text;

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
        RequestMessage.Method := 'POST';
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
}