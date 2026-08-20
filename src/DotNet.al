dotnet
{
    assembly(mscorlib)
    {
        type(System.Environment; DotNetEnvironment)
        {
        }

        type(Microsoft.Win32.RegistryKey; DotNetRegistryKey)
        {
        }

        type(Microsoft.Win32.RegistryHive; DotNetRegistryHive)
        {
        }

        type(Microsoft.Win32.RegistryView; DotNetRegistryView)
        {
        }

        type(System.IO.File; DotNetFile)
        {
        }

        type(System.IO.Path; DotNetPath)
        {
        }
    }

    assembly(System.Management)
    {
        type(System.Management.ManagementObjectSearcher; DotNetManagementObjectSearcher)
        {
        }

        type(System.Management.ManagementObjectCollection; DotNetManagementObjectCollection)
        {
        }

        type(System.Management.ManagementObject; DotNetManagementObject)
        {
        }
    }

    assembly("Microsoft.Data.SqlClient")
    {
        type("Microsoft.Data.SqlClient.SqlConnection"; DotNetSqlConnection)
        {
        }

        type("Microsoft.Data.SqlClient.SqlCommand"; DotNetSqlCommand)
        {
        }

        type("Microsoft.Data.SqlClient.SqlDataReader"; DotNetSqlDataReader)
        {
        }
    }
}