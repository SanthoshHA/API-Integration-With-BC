codeunit 50101 "Sales Invoice Management"
{
    procedure InsertSalesInvoice(documents: Text): Text
    var
        JArray: JsonArray;
        JArrayToken: JsonToken;
        JObject: JsonObject;
        SINumbers: List of [Text];
    begin
        if ((documents = '') or (documents = '[]')) then
            Error(NoDocumentsExistErr);

        JArray.ReadFrom(documents);
        foreach JArrayToken in JArray do begin
            JObject := JArrayToken.AsObject();
            SINumbers.Add(CreateSalesHeader(JObject));
        end;
        exit(StrSubstNo(InvoiceCountMsg, SINumbers.Count()))
    end;

    local procedure CreateSalesHeader(var JObject: JsonObject): Code[20];
    var
        SalesHeader: Record "Sales Header";
        JToken: JsonToken;
        LineJsonArray: JsonArray;
        LineJsonArrayToken: JsonToken;
        LineJsonObject: JsonObject;
        LinesJsonText: Text;
    begin
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader."No." := '';
        SalesHeader.Insert(true);

        if JSONMgmtHelper.GetJsonToken(JObject, sellToCustomerNoLbl, JToken) then
            SalesHeader.Validate("Sell-to Customer No.", JToken.AsValue().AsText());

        if JSONMgmtHelper.GetJsonToken(JObject, postingDateLbl, JToken) then
            SalesHeader.Validate("Posting Date", JToken.AsValue().AsDate());

        if JSONMgmtHelper.GetJsonToken(JObject, dueDateLbl, JToken) then
            SalesHeader.Validate("Due Date", JToken.AsValue().AsDate());

        if JSONMgmtHelper.GetJsonToken(JObject, externalDocumentNoLbl, JToken) then
            SalesHeader.Validate("External Document No.", JToken.AsValue().AsText());

        if JSONMgmtHelper.GetJsonToken(JObject, yourReferenceLbl, JToken) then
            SalesHeader.Validate("Your Reference", JToken.AsValue().AsText());

        if JSONMgmtHelper.GetJsonToken(JObject, salespersonCodeLbl, JToken) then
            SalesHeader.Validate("Salesperson Code", JToken.AsValue().AsText());

        SalesHeader.Modify(true);

        // Read lines and create sales line
        if JObject.Get(salesLinesLbl, JToken) then begin
            LineJsonArray := JToken.AsArray();
            foreach LineJsonArrayToken in LineJsonArray do begin
                LineJsonObject := LineJsonArrayToken.AsObject();
                CreateSalesLines(SalesHeader, LineJsonObject);
            end;
        end;
        exit(SalesHeader."No.");
    end;

    local procedure CreateSalesLines(SalesHeader: Record "Sales Header"; JObject: JsonObject)
    var
        SalesLine: Record "Sales Line";
        JToken: JsonToken;
        SalesLineType: Enum "Sales Line Type";
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";

        if JSONMgmtHelper.GetJsonToken(JObject, lineNoLbl, JToken) then
            SalesLine.Validate("Line No.", JToken.AsValue().AsInteger());

        SalesLine.Insert(true);

        if JSONMgmtHelper.GetJsonToken(JObject, typeLbl, JToken) then begin
            Evaluate(SalesLineType, JToken.AsValue().AsText());
            SalesLine.Validate(Type, SalesLineType);
        end;

        if JSONMgmtHelper.GetJsonToken(JObject, noLbl, JToken) then
            SalesLine.Validate("No.", JToken.AsValue().AsText());

        if JSONMgmtHelper.GetJsonToken(JObject, descriptionLbl, JToken) then
            SalesLine.Validate(Description, JToken.AsValue().AsText());

        if JSONMgmtHelper.GetJsonToken(JObject, quantityLbl, JToken) then
            if JToken.AsValue().AsDecimal() > 0 then
                SalesLine.Validate(Quantity, JToken.AsValue().AsDecimal());

        if JSONMgmtHelper.GetJsonToken(JObject, unitPriceLbl, JToken) then
            if JToken.AsValue().AsDecimal() > 0 then
                SalesLine.Validate("Unit Price", JToken.AsValue().AsDecimal());

        if JSONMgmtHelper.GetJsonToken(JObject, lineDiscountLbl, JToken) then
            if JToken.AsValue().AsDecimal() > 0 then
                SalesLine.Validate("Line Discount %", JToken.AsValue().AsDecimal());

        if JSONMgmtHelper.GetJsonToken(JObject, lineDiscountAmountLbl, JToken) then
            if JToken.AsValue().AsDecimal() > 0 then
                SalesLine.Validate("Line Discount Amount", JToken.AsValue().AsDecimal());

        SalesLine.Modify(true);
    end;

    var
        JSONMgmtHelper: Codeunit "JSON Management Helper";
        NoDocumentsExistErr: Label 'No documents exits.';
        InvoiceCountMsg: Label '%1 Invoice(s) are created in Business Central';
        salesLinesLbl: Label 'salesLines', Locked = true;
        sellToCustomerNoLbl: Label 'sellToCustomerNo', Locked = true;
        postingDateLbl: Label 'postingDate', Locked = true;
        dueDateLbl: Label 'dueDate', Locked = true;
        externalDocumentNoLbl: Label 'externalDocumentNo', Locked = true;
        yourReferenceLbl: Label 'yourReference', Locked = true;
        salespersonCodeLbl: Label 'salespersonCode', Locked = true;
        invoiceTypeLbl: Label 'invoiceType', Locked = true;
        contractNumberLbl: Label 'contractNumber', Locked = true;
        vinLbl: Label 'vin', Locked = true;
        lineNoLbl: Label 'lineNo', Locked = true;
        typeLbl: Label 'type', Locked = true;
        noLbl: Label 'no', Locked = true;
        descriptionLbl: Label 'description', Locked = true;
        quantityLbl: Label 'quantity', Locked = true;
        unitPriceLbl: Label 'unitPrice', Locked = true;
        lineDiscountLbl: Label 'lineDiscount', Locked = true;
        lineDiscountAmountLbl: Label 'lineDiscountAmount', Locked = true;
}