codeunit 50103 "Customer Management"
{
    procedure InsertCustomer(customers: Text): Text
    var
        JArray: JsonArray;
        JArrayToken: JsonToken;
        JObject: JsonObject;
        CustList: List of [Text];
    begin
        if ((customers = '') or (customers = '[]')) then
            Error(NoCustomersExistErr);

        JArray.ReadFrom(customers);
        foreach JArrayToken in JArray do begin
            JObject := JArrayToken.AsObject();
            CustList.Add(CreateCustomer(JObject));
        end;
        exit(StrSubstNo(InvoiceCountMsg, CustList.Count()))
    end;

    local procedure CreateCustomer(var JObject: JsonObject): Code[20];
    var
        Customer: Record Customer;
        ContactType: Enum "Contact Type";
        JToken: JsonToken;
    begin
        Customer.Init();
        Customer.Insert(true);

        if JSONMgmtHelper.GetJsonToken(JObject, displayNameLbl, JToken) then
            Customer.Validate(Name, JToken.AsValue().AsText());

        if JSONMgmtHelper.GetJsonToken(JObject, typeLbl, JToken) then begin
            Evaluate(ContactType, JToken.AsValue().AsText());
            Customer.Validate("Contact Type", ContactType);
        end;

        if JSONMgmtHelper.GetJsonToken(JObject, addressLine1Lbl, JToken) then
            Customer.Validate(Address, JToken.AsValue().AsText());

        if JSONMgmtHelper.GetJsonToken(JObject, addressLine1Lb2, JToken) then
            Customer.Validate("Address 2", JToken.AsValue().AsText());

        if JSONMgmtHelper.GetJsonToken(JObject, cityLbl, JToken) then
            Customer.Validate(City, JToken.AsValue().AsText());

        if JSONMgmtHelper.GetJsonToken(JObject, contractNumberLbl, JToken) then
            Customer.Validate("Contract Number VFS", JToken.AsValue().AsInteger());

        Customer.Modify(true);

        exit(Customer."No.");
    end;


    var
        JSONMgmtHelper: Codeunit "JSON Management Helper";
        NoCustomersExistErr: Label 'No customers exits.';
        InvoiceCountMsg: Label '%1 Customer(s) are created in Business Central';
        displayNameLbl: Label 'displayName', Locked = true;
        typeLbl: Label 'type', Locked = true;
        addressLine1Lbl: Label 'addressLine1', Locked = true;
        addressLine1Lb2: Label 'addressLine2', Locked = true;
        cityLbl: Label 'city', Locked = true;
        contractNumberLbl: Label 'contractNumber', Locked = true;
}