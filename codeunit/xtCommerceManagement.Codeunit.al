/// <summary>
/// Codeunit xtCommerce Management (ID 61000).
/// </summary>
codeunit 61000 "xtCommerce Management"
{
    procedure SendRequestFromServOrder()
    var
        //AurosanSetup: record "Aurosan Setup";
        JsonString: Text;
    begin
        JsonString :=
            '{' +
            '"to": {' +
                '"company": "Receiver Inc.",' +
                '"first_name": "Max",' +
                '"last_name": "Mustermann",' +
                '"street": "Beispielstrasse",' +
                '"street_no": "42",' +
                '"city": "Hamburg",' +
                '"zip_code": "22100",' +
                '"country": "DE"' +
            '},' +
            '"package": {' +
                '"weight": 1.5,' +
                '"length": 20,' +
                '"width": 20,' +
                '"height": 20,' +
                '"type": "parcel"' +
            '},' +
            '"carrier": "dhl",' +
            '"service": "standard",' +
            '"reference_number": "ref123456",' +
            '"notification_email": "person@example.com",' +
            '"create_shipping_label": true' +
            '}';

        //AurosanSetup.get;
        message(POST_Request('https://api.shipcloud.io/v1/shipments', JsonString));
    end;
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


    procedure POST_Request(uri: Text; _queryObj: Text) responseText: Text;

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
    //Aurosan: record "aurosan setup";
    begin

        // Add the payload to the content
        //aurosan.get;

        RequestHeaders := Client.DefaultRequestHeaders();
        RequestHeaders.Add('Authorization', 'Basic ' + Base64Convert.ToBase64('4d7673b559906d42ad9b659343f9d0c8:4d7673b559906d42ad9b659343f9d0c8'));

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
}