codeunit 50102 "JSON Management Helper"
{
    procedure GetJsonToken(JObject: JsonObject; FieldKey: Text; var JToken: JsonToken): Boolean
    begin
        if not JObject.Get(FieldKey, JToken) then
            exit(false);

        if JToken.AsValue().IsNull then
            exit(false);

        exit(true);
    end;
}