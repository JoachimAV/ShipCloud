/// <summary>
/// Codeunit BC2SC_ShipCloud Event Mgt. (ID 61001).
/// </summary>
codeunit 61001 "BC2SC_ShipCloud Event Mgt."
{


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeConfirmSalesPost', '', true, true)]
    local procedure "Sales-Post (Yes/No)_OnBeforeConfirmSalesPost"
    (
        var SalesHeader: Record "Sales Header";
        var HideDialog: Boolean;
        var IsHandled: Boolean;
        var DefaultOption: Integer;
        var PostAndSend: Boolean
    )
    var
        TransportHeader: Record "BC2SC_Transport Header";
        ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
        ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
        lbl001: label 'Create Transport for Sales Order %1?';


    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        ShipCloudSetup.get;
        if not ShipCloudSetup."Cr. Transp. w. Reg. Whse. Pick" then
            exit;

        TransportHeader.Setrange("Source Document Type", TransportHeader."Source Document Type"::"Sales Order");
        TransportHeader.setrange("Source Document No.", Salesheader."no.");
        if TransportHeader.findfirst then
            exit;

        if Confirm(lbl001, true, SalesHeader."No.") then
            ShipCloudMgt.CreateTranspFromSalesOrder(Salesheader);

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post + Print", 'OnBeforeConfirmPost', '', true, true)]
    local procedure "Sales-Post + Print_OnBeforeConfirmPost"
    (
        var SalesHeader: Record "Sales Header";
        var HideDialog: Boolean;
        var IsHandled: Boolean;
        var SendReportAsEmail: Boolean;
        var DefaultOption: Integer
    )
    var
        ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
        TransportHeader: record "BC2SC_Transport Header";
        ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
        lbl001: label 'Create Transport for Sales Order %1?';


    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        ShipCloudSetup.get;
        if not ShipCloudSetup."Cr. Transp. w. Reg. Whse. Pick" then
            exit;

        TransportHeader.Setrange("Source Document Type", TransportHeader."Source Document Type"::"Sales Order");
        TransportHeader.setrange("Source Document No.", Salesheader."no.");
        if TransportHeader.findfirst then
            exit;

        if Confirm(lbl001, true, SalesHeader."No.") then
            ShipCloudMgt.CreateTranspFromSalesOrder(Salesheader);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post (Yes/No)", 'OnBeforeConfirmServPost', '', true, true)]
    local procedure "Service-Post (Yes/No)_OnBeforeConfirmServPost"
    (
        var ServiceHeader: Record "Service Header";
        var HideDialog: Boolean;
        var Ship: Boolean;
        var Consume: Boolean;
        var Invoice: Boolean;
        var IsHandled: Boolean;
        PreviewMode: Boolean;
        var ServiceLine: Record "Service Line"
    )
    var
        ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
        TransportHeader: Record "BC2SC_Transport Header";
        ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
        lbl001: label 'Create Transport for Service Order %1?';


    begin
        if ServiceHeader."Document Type" <> ServiceHeader."Document Type"::Order then
            exit;

        ShipCloudSetup.get;
        if not ShipCloudSetup."Cr. Transp. w. Serv.-Post" then
            exit;

        TransportHeader.Setrange("Source Document Type", TransportHeader."Source Document Type"::"Service Order");
        TransportHeader.setrange("Source Document No.", ServiceHeader."no.");
        if TransportHeader.findfirst then
            exit;

        if Confirm(lbl001, true, ServiceHeader."No.") then
            ShipCloudMgt.CreateTranspFromServiceOrder(ServiceHeader);

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post+Print", 'OnBeforeConfirmPost', '', true, true)]
    local procedure "Service-Post+Print_OnBeforeConfirmPost"
    (
        var ServiceHeader: Record "Service Header";
        var HideDialog: Boolean;
        var Ship: Boolean;
        var Consume: Boolean;
        var Invoice: Boolean;
        var IsHandled: Boolean;
        var PassedServLine: Record "Service Line"
    )
    var
        ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
        TransportHeader: record "BC2SC_Transport Header";
        ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
        lbl001: label 'Create Transport for Service Order %1?';


    begin
        if ServiceHeader."Document Type" <> ServiceHeader."Document Type"::Order then
            exit;

        ShipCloudSetup.get;
        if not ShipCloudSetup."Cr. Transp. w. Serv.-Post" then
            exit;

        TransportHeader.Setrange("Source Document Type", TransportHeader."Source Document Type"::"Service Order");
        TransportHeader.setrange("Source Document No.", ServiceHeader."no.");
        if TransportHeader.findfirst then
            exit;

        if Confirm(lbl001, true, ServiceHeader."No.") then
            ShipCloudMgt.CreateTranspFromServiceOrder(ServiceHeader);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Act.-Post (Yes/No)", 'OnBeforeConfirmPost', '', true, true)]
    local procedure "Whse.-Act.-Post (Yes/No)_OnBeforeConfirmPost"
    (
        var WhseActivLine: Record "Warehouse Activity Line";
        var HideDialog: Boolean;
        var Selection: Integer;
        var DefaultOption: Integer;
        var IsHandled: Boolean;
        var PrintDoc: Boolean
    )
    var
        TransportHeader: Record "BC2SC_Transport Header";
        ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        SalesHeader: Record "Sales Header";
        ShippingAgent: Record "Shipping Agent";
        ShipCloudMgt: Codeunit "BC2SC_ShipCloud Management";
        lbl001: label 'Create Transport for Sales Order %1?';
    begin
        ShipCloudSetup.get;
        if not ShipCloudSetup."Cr. Transp. w. Reg. Whse. Pick" then
            exit;

        if WhseActivLine."Source Type" = 37 then begin
            TransportHeader.Setrange("Source Document Type", WhseActivLine."Source Subtype");
            TransportHeader.setrange("Source Document No.", WhseActivLine."Source No.");
            if not TransportHeader.findfirst then begin
                if not SalesHeader.get(WhseActivLine."Source Subtype", WhseActivLine."Source No.") then
                    exit;
                if not ShippingAgent.get(SalesHeader."Shipping Agent Code") then
                    exit;

                if ShippingAgent."BC2SC_Shipcloud Agent Name" <> '' then
                    if Confirm(lbl001, true, SalesHeader."No.") then begin
                        WarehouseActivityHeader.get(WhseActivLine."Activity Type", WhseActivLine."No.");
                        ShipCloudMgt.CreateTranspFromWhseActHeader(WarehouseActivityHeader);
                    end;
            end;
        end;

    end;


}
