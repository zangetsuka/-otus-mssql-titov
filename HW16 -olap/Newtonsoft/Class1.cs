using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using Newtonsoft.Json.Linq;

public class JsonFunctions
{
    [SqlFunction]
    public static SqlString GetJsonValue(SqlString json, SqlString key)
    {
        if (json.IsNull || key.IsNull)
            return SqlString.Null;

        var jsonObject = JObject.Parse(json.Value);
        var value = jsonObject.SelectToken(key.Value)?.ToString();

        return value != null ? new SqlString(value) : SqlString.Null;
    }
}
